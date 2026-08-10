#!/usr/bin/env perl
use strict;
use warnings;
use Digest::SHA qw(sha256_hex);
use FindBin;
use File::Spec;
use JSON::PP qw(decode_json);
use Scalar::Util qw(blessed looks_like_number);

my $root = File::Spec->rel2abs(File::Spec->catdir($FindBin::Bin, '..'));

sub bytes {
    my ($path) = @_;
    open my $handle, '<:raw', $path or die "Cannot read $path: $!\n";
    local $/;
    return <$handle>;
}

sub json {
    my ($relative) = @_;
    return decode_json(bytes(File::Spec->catfile($root, $relative)));
}

sub assert_true {
    my ($condition, $message) = @_;
    die "$message\n" unless $condition;
}

my $canonical_json = JSON::PP->new->canonical->allow_nonref->utf8;

sub json_clone {
    my ($value) = @_;
    return decode_json($canonical_json->encode($value));
}

sub json_equal {
    my ($lhs, $rhs) = @_;
    return $canonical_json->encode($lhs) eq $canonical_json->encode($rhs);
}

sub is_json_boolean {
    my ($value) = @_;
    return defined($value)
        && blessed($value)
        && $value->isa('JSON::PP::Boolean');
}

sub matches_json_type {
    my ($value, $type) = @_;
    return !defined($value) if $type eq 'null';
    return ref($value) eq 'HASH' if $type eq 'object';
    return ref($value) eq 'ARRAY' if $type eq 'array';
    return is_json_boolean($value) if $type eq 'boolean';
    return defined($value) && !ref($value) if $type eq 'string';
    return defined($value) && !ref($value) && looks_like_number($value)
        if $type eq 'number';
    return defined($value) && !ref($value) && looks_like_number($value)
        && int($value) == $value if $type eq 'integer';
    return 0;
}

sub resolve_local_ref {
    my ($root_schema, $reference) = @_;
    die "Only local JSON Schema references are supported: $reference\n"
        unless $reference =~ m{^#/};
    my $value = $root_schema;
    for my $token (split '/', substr($reference, 2)) {
        $token =~ s/~1/\//g;
        $token =~ s/~0/~/g;
        die "Unresolved JSON Schema reference: $reference\n"
            unless ref($value) eq 'HASH' && exists $value->{$token};
        $value = $value->{$token};
    }
    return $value;
}

sub schema_errors {
    my ($schema, $value, $root_schema, $path) = @_;
    $root_schema //= $schema;
    $path //= '$';
    my @errors;

    if (exists $schema->{'$ref'}) {
        push @errors, schema_errors(
            resolve_local_ref($root_schema, $schema->{'$ref'}),
            $value,
            $root_schema,
            $path
        );
    }

    if (exists $schema->{type}) {
        my @types = ref($schema->{type}) eq 'ARRAY'
            ? @{$schema->{type}} : ($schema->{type});
        unless (grep { matches_json_type($value, $_) } @types) {
            push @errors, "$path: expected type " . join('|', @types);
            return @errors;
        }
    }

    if (exists $schema->{const} && !json_equal($value, $schema->{const})) {
        push @errors, "$path: const mismatch";
    }
    if (exists $schema->{enum}
        && !grep { json_equal($value, $_) } @{$schema->{enum}}) {
        push @errors, "$path: value is outside enum";
    }

    if (exists $schema->{oneOf}) {
        my $matching = 0;
        for my $branch (@{$schema->{oneOf}}) {
            my @branch_errors = schema_errors($branch, $value, $root_schema, $path);
            ++$matching unless @branch_errors;
        }
        push @errors, "$path: oneOf matched $matching branches" unless $matching == 1;
    }
    if (exists $schema->{allOf}) {
        for my $branch (@{$schema->{allOf}}) {
            push @errors, schema_errors($branch, $value, $root_schema, $path);
        }
    }
    if (exists $schema->{if}) {
        my @condition_errors = schema_errors($schema->{if}, $value, $root_schema, $path);
        if (!@condition_errors && exists $schema->{then}) {
            push @errors, schema_errors($schema->{then}, $value, $root_schema, $path);
        } elsif (@condition_errors && exists $schema->{else}) {
            push @errors, schema_errors($schema->{else}, $value, $root_schema, $path);
        }
    }

    if (ref($value) eq 'HASH') {
        if (exists $schema->{required}) {
            for my $key (@{$schema->{required}}) {
                push @errors, "$path.$key: required property is missing"
                    unless exists $value->{$key};
            }
        }
        if (exists $schema->{properties}) {
            for my $key (keys %{$schema->{properties}}) {
                next unless exists $value->{$key};
                push @errors, schema_errors(
                    $schema->{properties}{$key},
                    $value->{$key},
                    $root_schema,
                    "$path.$key"
                );
            }
            if (exists $schema->{additionalProperties}
                && !$schema->{additionalProperties}) {
                my %allowed = map { $_ => 1 } keys %{$schema->{properties}};
                for my $key (keys %$value) {
                    push @errors, "$path.$key: additional property is forbidden"
                        unless $allowed{$key};
                }
            }
        }
    }

    if (ref($value) eq 'ARRAY') {
        push @errors, "$path: fewer than $schema->{minItems} items"
            if exists $schema->{minItems} && @$value < $schema->{minItems};
        push @errors, "$path: more than $schema->{maxItems} items"
            if exists $schema->{maxItems} && @$value > $schema->{maxItems};
        if (exists $schema->{uniqueItems} && $schema->{uniqueItems}) {
            for my $left (0 .. $#$value) {
                for my $right ($left + 1 .. $#$value) {
                    push @errors, "$path: duplicate items at $left and $right"
                        if json_equal($value->[$left], $value->[$right]);
                }
            }
        }
        if (exists $schema->{items}) {
            for my $index (0 .. $#$value) {
                push @errors, schema_errors(
                    $schema->{items},
                    $value->[$index],
                    $root_schema,
                    "$path\[$index\]"
                );
            }
        }
    }

    if (defined($value) && !ref($value) && !is_json_boolean($value)) {
        push @errors, "$path: shorter than $schema->{minLength} characters"
            if exists $schema->{minLength} && length($value) < $schema->{minLength};
        push @errors, "$path: longer than $schema->{maxLength} characters"
            if exists $schema->{maxLength} && length($value) > $schema->{maxLength};
        if (exists $schema->{pattern}) {
            my $pattern = $schema->{pattern};
            my $matched = eval { $value =~ /$pattern/ ? 1 : 0 };
            die "Invalid pattern in JSON Schema at $path: $@" if $@;
            push @errors, "$path: pattern mismatch" unless $matched;
        }
        if (exists $schema->{format} && $schema->{format} eq 'uuid') {
            push @errors, "$path: invalid uuid"
                unless $value =~ /^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$/;
        }
        if (exists $schema->{format} && $schema->{format} eq 'date-time') {
            push @errors, "$path: invalid date-time"
                unless $value =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}(?:\.[0-9]+)?Z$/;
        }
    }

    if (defined($value) && !ref($value) && looks_like_number($value)) {
        push @errors, "$path: below minimum $schema->{minimum}"
            if exists $schema->{minimum} && $value < $schema->{minimum};
        push @errors, "$path: above maximum $schema->{maximum}"
            if exists $schema->{maximum} && $value > $schema->{maximum};
        push @errors, "$path: not above exclusiveMinimum $schema->{exclusiveMinimum}"
            if exists $schema->{exclusiveMinimum} && $value <= $schema->{exclusiveMinimum};
        push @errors, "$path: not below exclusiveMaximum $schema->{exclusiveMaximum}"
            if exists $schema->{exclusiveMaximum} && $value >= $schema->{exclusiveMaximum};
    }

    return @errors;
}

sub assert_schema_valid {
    my ($schema, $value, $label) = @_;
    my @errors = schema_errors($schema, $value);
    die "$label unexpectedly violates its JSON Schema:\n  "
        . join("\n  ", @errors) . "\n" if @errors;
}

sub assert_schema_rejected {
    my ($schema, $value, $label, $expected_path) = @_;
    my @errors = schema_errors($schema, $value);
    assert_true(@errors > 0, "$label was unexpectedly accepted by its JSON Schema");
    assert_true(
        grep { index($_, $expected_path) >= 0 } @errors,
        "$label was rejected, but not for $expected_path:\n  " . join("\n  ", @errors)
    );
}

sub catalog_extended_semantic_errors {
    my ($resource) = @_;
    my @errors;
    if (($resource->{category} // '') eq 'sticker') {
        my $ratio = $resource->{intrinsicAspectRatio} // {};
        if (($ratio->{width} // 0) * ($resource->{pixelHeight} // 0)
            != ($ratio->{height} // 0) * ($resource->{pixelWidth} // 0)) {
            push @errors, 'sticker intrinsic aspect ratio differs from payload dimensions';
        }
        my %seen_tags;
        for my $tag (@{($resource->{localizedTags} // {})->{fr} // []}) {
            push @errors, "duplicate French sticker tag: $tag" if $seen_tags{$tag}++;
        }
    } elsif (($resource->{category} // '') eq 'decorativeFrame') {
        my $source = $resource->{sourceCapInsetsPixels} // {};
        my $destination = $resource->{destinationCapInsets} // {};
        push @errors, 'horizontal source cap-inset sum must be below pixelWidth'
            unless ($source->{left} // 0) + ($source->{right} // 0)
                < ($resource->{pixelWidth} // 0);
        push @errors, 'vertical source cap-inset sum must be below pixelHeight'
            unless ($source->{top} // 0) + ($source->{bottom} // 0)
                < ($resource->{pixelHeight} // 0);
        push @errors, 'horizontal destination cap-inset sum must be below one'
            unless ($destination->{left} // 0) + ($destination->{right} // 0) < 1;
        push @errors, 'vertical destination cap-inset sum must be below one'
            unless ($destination->{top} // 0) + ($destination->{bottom} // 0) < 1;
    }
    return @errors;
}

for my $json_document (
    'docs/photoalbum-format-v1.schema.json',
    'docs/schema/catalog-resources-v1.schema.json',
    'docs/schema/layout-templates-v1.schema.json',
    'docs/examples/Minimal.photoalbum/manifest.json',
    'docs/examples/Minimal.photoalbum/checksums.json',
    'docs/examples/invalid/wrong-generation-manifest.json',
    'docs/examples/invalid/path-traversal-manifest.json'
) {
    json($json_document);
}

my $photoalbum_schema = json('docs/photoalbum-format-v1.schema.json');
my $catalog_schema = json('docs/schema/catalog-resources-v1.schema.json');
my $layout_schema = json('docs/schema/layout-templates-v1.schema.json');
my $minimal_package = json('docs/examples/Minimal.photoalbum/manifest.json');
my $path_traversal = json('docs/examples/invalid/path-traversal-manifest.json');
my $wrong_generation = json('docs/examples/invalid/wrong-generation-manifest.json');

assert_schema_valid($photoalbum_schema, $minimal_package, 'Minimal.photoalbum manifest');
assert_schema_rejected(
    $photoalbum_schema,
    $path_traversal,
    'Path traversal fixture',
    '$.assets[0].relativePath'
);
my $repaired_path_fixture = json_clone($path_traversal);
$repaired_path_fixture->{assets}[0]{relativePath} = 'assets/safe.jpg';
assert_schema_valid(
    $photoalbum_schema,
    $repaired_path_fixture,
    'Path traversal fixture after replacing only its unsafe path'
);
assert_schema_rejected(
    $photoalbum_schema,
    $wrong_generation,
    'Wrong-generation fixture',
    '$.formatGeneration'
);

my @persisted_raw_mime_types = (
    'image/x-raw', 'image/x-adobe-dng', 'image/x-canon-cr2',
    'image/x-canon-crw', 'image/x-epson-erf', 'image/x-fuji-raf',
    'image/x-kodak-dcr', 'image/x-kodak-k25', 'image/x-kodak-kdc',
    'image/x-minolta-mrw', 'image/x-nikon-nef', 'image/x-olympus-orf',
    'image/x-panasonic-raw', 'image/x-panasonic-rw2', 'image/x-pentax-pef',
    'image/x-sigma-x3f', 'image/x-sony-arw', 'image/x-sony-sr2',
    'image/x-sony-srf'
);
for my $mime_type (@persisted_raw_mime_types) {
    my $raw_package = json_clone($minimal_package);
    push @{$raw_package->{assets}}, {
        id => '00000000-0000-4000-8000-000000000099',
        contentHash => ('a' x 64),
        mimeType => $mime_type,
        byteCount => 10,
        relativePath => 'assets/raw-original',
        pixelWidth => 1,
        pixelHeight => 1,
        originalFilename => 'original.raw',
        colorSpaceName => undef,
        isHDR => JSON::PP::false,
        source => 'files',
        capturedAt => undef,
        importedAt => '2026-08-06T12:00:00.000Z'
    };
    assert_schema_valid($photoalbum_schema, $raw_package, "RAW MIME $mime_type");
}

my $invalid_mime_package = json_clone($minimal_package);
push @{$invalid_mime_package->{assets}}, {
    id => '00000000-0000-4000-8000-000000000099',
    contentHash => ('a' x 64),
    mimeType => 'application/octet-stream',
    byteCount => 10,
    relativePath => 'assets/not-an-image',
    pixelWidth => 1,
    pixelHeight => 1,
    originalFilename => undef,
    colorSpaceName => undef,
    isHDR => JSON::PP::false,
    source => 'files',
    capturedAt => undef,
    importedAt => '2026-08-06T12:00:00.000Z'
};
assert_schema_rejected(
    $photoalbum_schema,
    $invalid_mime_package,
    'Unsupported photo MIME fixture',
    '$.assets[0].mimeType'
);

my $native_resource_package = json_clone($minimal_package);
push @{$native_resource_package->{catalogResources}}, {
    catalogID => 'shape.rectangle',
    catalogVersion => 1,
    payloadKind => 'nativeVector',
    rendererID => 'shape.rectangle'
};
assert_schema_valid(
    $photoalbum_schema,
    $native_resource_package,
    'Native-vector package resource'
);
my $mixed_native_resource_package = json_clone($native_resource_package);
$mixed_native_resource_package->{catalogResources}[0]{relativePath} = 'catalog-resources/forbidden.png';
assert_schema_rejected(
    $photoalbum_schema,
    $mixed_native_resource_package,
    'Native-vector resource carrying a fallback file',
    '$.catalogResources[0]'
);

my $asset_resource_package = json_clone($minimal_package);
push @{$asset_resource_package->{catalogResources}}, {
    catalogID => 'album.classicSpiral',
    catalogVersion => 1,
    payloadKind => 'asset',
    relativePath => 'catalog-resources/background.png',
    mimeType => 'image/png',
    byteCount => 10,
    sha256 => ('b' x 64)
};
assert_schema_valid($photoalbum_schema, $asset_resource_package, 'Asset package resource');
my $mixed_asset_resource_package = json_clone($asset_resource_package);
$mixed_asset_resource_package->{catalogResources}[0]{rendererID} = 'shape.rectangle';
assert_schema_rejected(
    $photoalbum_schema,
    $mixed_asset_resource_package,
    'Asset resource carrying a renderer ID',
    '$.catalogResources[0]'
);

# CAT-009 publishes the complete metadata shape before Lot 2 publishes any
# sticker or decorative-frame payload. These synthetic descriptors prove that
# the schema is usable and that cross-field invariants outside JSON Schema are
# enforced by this validator.
my $future_sticker = {
    catalogID => 'sticker.travel.compass',
    catalogVersion => 1,
    category => 'sticker',
    localizedNameKey => 'sticker.travel.compass',
    payloadKind => 'asset',
    relativePath => 'Sources/AppModule/Resources/Stickers/compass.png',
    mimeType => 'image/png',
    byteCount => 10,
    pixelWidth => 200,
    pixelHeight => 100,
    sha256 => ('c' x 64),
    localizedTags => { fr => ['voyage', 'boussole', 'orientation'] },
    stickerCategory => 'travel',
    intrinsicAspectRatio => { width => 2, height => 1 },
    license => 'project-generated-original',
    source => 'future-lot-2-license-proof'
};
my $future_frame = {
    catalogID => 'frame.whiteBorder',
    catalogVersion => 1,
    category => 'decorativeFrame',
    localizedNameKey => 'frame.whiteBorder',
    payloadKind => 'asset',
    relativePath => 'Sources/AppModule/Resources/Frames/white-border.png',
    mimeType => 'image/png',
    byteCount => 10,
    pixelWidth => 16,
    pixelHeight => 16,
    sha256 => ('d' x 64),
    sourceCapInsetsPixels => { top => 2, left => 2, bottom => 2, right => 2 },
    destinationCapInsets => { top => 0.1, left => 0.1, bottom => 0.1, right => 0.1 },
    nineSliceContract => {
        algorithm => 'nineSliceStretch',
        sourceCoordinates => 'orientedPixels',
        destinationCoordinates => 'fractionOfUnrotatedElementBounds',
        interpolation => 'bilinear',
        composition => 'sourceOverAboveMaskedPhotoAndStroke',
        followsElementTransformAndClip => JSON::PP::true,
        goldenImage => {
            relativePath => 'golden/frame-nine-slice-v1/white-border.png',
            mimeType => 'image/png',
            pixelWidth => 64,
            pixelHeight => 48,
            byteCount => 10,
            sha256 => ('e' x 64)
        }
    },
    license => 'project-generated-original',
    source => 'future-lot-2-license-proof'
};
for my $future_resource ($future_sticker, $future_frame) {
    my $future_registry = { registryVersion => 1, resources => [$future_resource] };
    assert_schema_valid(
        $catalog_schema,
        $future_registry,
        "Future $future_resource->{category} registry descriptor"
    );
    my @semantic_errors = catalog_extended_semantic_errors($future_resource);
    assert_true(
        !@semantic_errors,
        "Valid future $future_resource->{category} descriptor failed semantics: "
            . join(', ', @semantic_errors)
    );
}

my $sticker_without_tags = json_clone($future_sticker);
delete $sticker_without_tags->{localizedTags};
assert_schema_rejected(
    $catalog_schema,
    { registryVersion => 1, resources => [$sticker_without_tags] },
    'Sticker without localized French tags',
    '$.resources[0]'
);
my $sticker_with_duplicate_tag = json_clone($future_sticker);
$sticker_with_duplicate_tag->{localizedTags}{fr} = ['voyage', 'voyage'];
assert_schema_rejected(
    $catalog_schema,
    { registryVersion => 1, resources => [$sticker_with_duplicate_tag] },
    'Sticker with duplicate localized French tags',
    '$.resources[0]'
);
my $sticker_with_wrong_ratio = json_clone($future_sticker);
$sticker_with_wrong_ratio->{intrinsicAspectRatio} = { width => 3, height => 2 };
assert_schema_valid(
    $catalog_schema,
    { registryVersion => 1, resources => [$sticker_with_wrong_ratio] },
    'Sticker ratio requiring a cross-field check'
);
assert_true(
    scalar(catalog_extended_semantic_errors($sticker_with_wrong_ratio)),
    'Sticker payload/ratio mismatch escaped cross-field validation'
);
my $frame_with_invalid_source_sum = json_clone($future_frame);
$frame_with_invalid_source_sum->{sourceCapInsetsPixels}{left} = 8;
$frame_with_invalid_source_sum->{sourceCapInsetsPixels}{right} = 8;
assert_schema_valid(
    $catalog_schema,
    { registryVersion => 1, resources => [$frame_with_invalid_source_sum] },
    'Frame inset sums requiring a cross-field check'
);
assert_true(
    scalar(catalog_extended_semantic_errors($frame_with_invalid_source_sum)),
    'Invalid frame source inset sum escaped cross-field validation'
);

my $layouts = json('docs/layout-templates-v1.json');
assert_schema_valid($layout_schema, $layouts, 'Layout manifest');
assert_true($layouts->{manifestVersion} == 1, 'Invalid layout manifest version');
assert_true($layouts->{modelGeneration} eq 'album-photo-canvas-v1', 'Invalid layout generation');
assert_true(@{$layouts->{templates}} == 32, 'Exactly 32 initial templates are required');

my %template_ids;
for my $template (@{$layouts->{templates}}) {
    assert_true(!$template_ids{$template->{id}}++, "Duplicate template $template->{id}");
    assert_true($template->{id} =~ /^[a-z0-9][a-z0-9._-]{0,63}$/, "Invalid template ID $template->{id}");
    my (%slot_ids, @orders);
    for my $slot (@{$template->{slots}}) {
        assert_true(!$slot_ids{$slot->{id}}++, "Duplicate slot $slot->{id} in $template->{id}");
        push @orders, $slot->{readingOrder};
        my $geometry = $slot->{geometry};
        assert_true($geometry->{width} >= 0.05 && $geometry->{height} >= 0.05, "Slot too small in $template->{id}");
        assert_true($geometry->{centerX} >= 0 && $geometry->{centerX} <= 1, "Invalid centerX in $template->{id}");
        assert_true($geometry->{centerY} >= 0 && $geometry->{centerY} <= 1, "Invalid centerY in $template->{id}");
    }
    @orders = sort { $a <=> $b } @orders;
    for my $index (0 .. $#orders) {
        assert_true($orders[$index] == $index, "Non-contiguous readingOrder in $template->{id}");
    }
}

for my $count (1 .. 8) {
    my @matching = grep { $_->{id} =~ /^layout\.p$count\./ } @{$layouts->{templates}};
    assert_true(@matching == 4, "Photo count $count must have four variants");
    my @with_text = grep {
        my @text = grep { $_->{kind} eq 'text' } @{$_->{slots}};
        @text == 1;
    } @matching;
    assert_true(@with_text == 2, "Photo count $count must have two one-text variants");
}

my $catalog = json('docs/catalog-resources-v1.json');
assert_schema_valid($catalog_schema, $catalog, 'Catalog registry');
assert_true($catalog->{registryVersion} == 1, 'Invalid catalog registry version');
my $heart_path = 'M .50 .95 C .44 .88 .08 .65 .08 .34 C .08 .15 .21 .05 .36 .05 C .44 .05 .49 .10 .50 .17 C .51 .10 .56 .05 .64 .05 C .79 .05 .92 .15 .92 .34 C .92 .65 .56 .88 .50 .95 Z';
my %expected_shape_contracts = (
    'shape.rectangle' => {
        primitive => 'rectangle',
        parameters => { kind => 'bounds', x => 0, y => 0, width => 1, height => 1 },
        golden => 'golden/shape-masks-v1/shape-rectangle.pbm',
        sha256 => '2690338ccd22e03a38e6d80c6b21c9ef5dbdf0ba14ea888df47089d56ee1b8f1',
        insideSamples => 3072
    },
    'shape.roundedRectangle' => {
        primitive => 'roundedRectangle',
        parameters => {
            kind => 'roundedBounds', x => 0, y => 0, width => 1, height => 1,
            cornerRadiusFactor => 0.12,
            cornerRadiusRelativeTo => 'minElementDimension'
        },
        golden => 'golden/shape-masks-v1/shape-roundedRectangle.pbm',
        sha256 => '822ff8d71f44121bc84b4e0d5d4451ebece3317557f3751045156b971312aca1',
        insideSamples => 3048
    },
    'shape.circle' => {
        primitive => 'circle',
        parameters => {
            kind => 'centeredCircle', centerX => 0.5, centerY => 0.5,
            radiusFactor => 0.5, radiusRelativeTo => 'minElementDimension'
        },
        golden => 'golden/shape-masks-v1/shape-circle.pbm',
        sha256 => 'b1ea230295decfdd14b04d51a5e22274ae89180a6c993d75d6869f9000a1081b',
        insideSamples => 1804
    },
    'shape.oval' => {
        primitive => 'ellipse',
        parameters => {
            kind => 'ellipseInBounds', centerX => 0.5, centerY => 0.5,
            radiusX => 0.5, radiusY => 0.5
        },
        golden => 'golden/shape-masks-v1/shape-oval.pbm',
        sha256 => '1c22fbeb1c0030e72ea731536adcbb1575ad503a49a39f7a8d2a880de64dafd9',
        insideSamples => 2404
    },
    'shape.heart' => {
        primitive => 'cubicBezierPath',
        parameters => { kind => 'svgCubicPath', path => $heart_path },
        golden => 'golden/shape-masks-v1/shape-heart.pbm',
        sha256 => 'fda470ca05a0e8bfc923d726f9035df62b1673d743d8438de6bd58a8cdb116cd',
        insideSamples => 1656
    },
    'shape.star' => {
        primitive => 'alternatingRadialPolygon',
        parameters => {
            kind => 'alternatingRadialPolygon', centerX => 0.5, centerY => 0.5,
            vertexCount => 10, startAnglePi => -0.5, angularStepPi => 0.2,
            evenVertexRadius => 0.5, oddVertexRadius => 0.22
        },
        golden => 'golden/shape-masks-v1/shape-star.pbm',
        sha256 => '518a5fbb66784e12362ad264212651cd6284d1b0ff6284f846e9e8362afb8599',
        insideSamples => 990
    }
);
my %expected_background_ids = map { $_ => 1 } (
    'album.classicSpiral', 'album.travelKraft', 'album.minimalDark'
);
my %expected_frame_ids = map { $_ => 1 } (
    'frame.whiteBorder', 'frame.blackBorder', 'frame.kraftTape',
    'frame.travelStamp', 'frame.botanical', 'frame.instantPhoto'
);
my %catalog_keys;
my $background_count = 0;
my $shape_count = 0;
my $sticker_count = 0;
my $frame_count = 0;
my (%seen_background_ids, %seen_shape_ids, %seen_frame_ids);
my (%sticker_count_by_category, %sticker_tags_by_category);
for my $resource (@{$catalog->{resources}}) {
    my $key = $resource->{catalogID} . '@' . $resource->{catalogVersion};
    assert_true(!$catalog_keys{$key}++, "Duplicate catalog resource $key");
    my @semantic_errors = catalog_extended_semantic_errors($resource);
    assert_true(!@semantic_errors, "$key semantic error: " . join(', ', @semantic_errors));

    if ($resource->{payloadKind} eq 'asset') {
        my $path = File::Spec->catfile(
            $root,
            'Albumzh.swiftpm',
            split('/', $resource->{relativePath})
        );
        my $data = bytes($path);
        assert_true(length($data) == $resource->{byteCount}, "Byte count mismatch for $key");
        assert_true(sha256_hex($data) eq $resource->{sha256}, "SHA-256 mismatch for $key");
        assert_true($resource->{mimeType} eq 'image/png', "$key must use image/png");
        assert_true(substr($data, 0, 8) eq "\x89PNG\r\n\x1a\n", "$key is not a PNG");
        my ($width, $height) = unpack('NN', substr($data, 16, 8));
        assert_true(
            $width == $resource->{pixelWidth} && $height == $resource->{pixelHeight},
            "Dimensions mismatch for $key"
        );
    } else {
        for my $forbidden (qw(relativePath mimeType byteCount pixelWidth pixelHeight sha256 source)) {
            assert_true(!exists $resource->{$forbidden}, "$key nativeVector forbids $forbidden");
        }
    }

    if ($resource->{category} eq 'background') {
        ++$background_count;
        ++$seen_background_ids{$resource->{catalogID}};
        assert_true($resource->{payloadKind} eq 'asset', "$key must use an asset payload");
        assert_true($resource->{catalogVersion} == 1, "$key must remain version 1");
        assert_true($resource->{pixelWidth} * 5 == $resource->{pixelHeight} * 4, "$key is not exact 4:5");
    } elsif ($resource->{category} eq 'shape') {
        ++$shape_count;
        ++$seen_shape_ids{$resource->{catalogID}};
        assert_true($resource->{payloadKind} eq 'nativeVector', "$key must use nativeVector");
        assert_true($resource->{rendererID} eq $resource->{catalogID}, "Renderer mismatch for $key");
        assert_true($resource->{catalogVersion} == 1, "$key must remain version 1");
        assert_true($resource->{license} eq 'project-code', "$key has an unexpected license proof");
        my $expected = $expected_shape_contracts{$resource->{catalogID}};
        assert_true(defined $expected, "Unexpected v1 renderer $resource->{catalogID}");
        my $contract = $resource->{rendererContract};
        assert_true($contract->{coordinateSpace} eq 'unitBoundingBoxTopLeft', "Coordinate space mismatch for $key");
        assert_true($contract->{primitive} eq $expected->{primitive}, "Primitive mismatch for $key");
        assert_true(json_equal($contract->{parameters}, $expected->{parameters}), "Parameters mismatch for $key");
        assert_true($contract->{pathClosure} eq 'closed', "Path closure mismatch for $key");
        assert_true($contract->{fillRule} eq 'nonzero', "Fill rule mismatch for $key");
        assert_true($contract->{intrinsicStroke} eq 'none', "Intrinsic stroke mismatch for $key");
        assert_true($contract->{clipToElementBounds}, "Element clipping mismatch for $key");

        my $golden = $contract->{goldenMask};
        assert_true($golden->{relativePath} eq $expected->{golden}, "Golden path mismatch for $key");
        assert_true($golden->{format} eq 'pbm-p1', "Golden format mismatch for $key");
        assert_true($golden->{sampleLocation} eq 'pixelCenter', "Golden sampling mismatch for $key");
        assert_true($golden->{width} == 64 && $golden->{height} == 48, "Golden dimensions mismatch for $key");
        my $golden_path = File::Spec->catfile($root, 'docs', split('/', $golden->{relativePath}));
        my $golden_data = bytes($golden_path);
        assert_true(length($golden_data) == $golden->{byteCount}, "Golden byte count mismatch for $key");
        assert_true(sha256_hex($golden_data) eq $golden->{sha256}, "Golden manifest SHA mismatch for $key");
        assert_true($golden->{sha256} eq $expected->{sha256}, "Frozen golden SHA mismatch for $key");
        my @pbm_tokens = split /\s+/, $golden_data;
        assert_true(shift(@pbm_tokens) eq 'P1', "Golden PBM magic mismatch for $key");
        assert_true(shift(@pbm_tokens) == 64 && shift(@pbm_tokens) == 48, "Golden PBM header mismatch for $key");
        assert_true(@pbm_tokens == 64 * 48, "Golden PBM sample count mismatch for $key");
        assert_true(
            !(grep { $_ ne '0' && $_ ne '1' } @pbm_tokens),
            "Golden PBM contains a non-bit sample for $key"
        );
        my $inside_samples = grep { $_ eq '1' } @pbm_tokens;
        assert_true($inside_samples == $expected->{insideSamples}, "Golden fill count mismatch for $key");
    } elsif ($resource->{category} eq 'sticker') {
        ++$sticker_count;
        ++$sticker_count_by_category{$resource->{stickerCategory}};
        $sticker_tags_by_category{$resource->{stickerCategory}}{$_} = 1
            for @{$resource->{localizedTags}{fr}};
    } elsif ($resource->{category} eq 'decorativeFrame') {
        ++$frame_count;
        ++$seen_frame_ids{$resource->{catalogID}};
        my $golden = $resource->{nineSliceContract}{goldenImage};
        my $golden_path = File::Spec->catfile($root, 'docs', split('/', $golden->{relativePath}));
        my $golden_data = bytes($golden_path);
        assert_true(length($golden_data) == $golden->{byteCount}, "Nine-slice golden byte count mismatch for $key");
        assert_true(sha256_hex($golden_data) eq $golden->{sha256}, "Nine-slice golden SHA mismatch for $key");
    }
}
assert_true($background_count == 3, 'Exactly three lot-1 backgrounds are required');
assert_true($shape_count == 6, 'Exactly six v1 shape contracts are required');
assert_true(
    json_equal([sort keys %seen_background_ids], [sort keys %expected_background_ids]),
    'Lot-1 background IDs differ from the frozen public registry'
);
assert_true(
    json_equal([sort keys %seen_shape_ids], [sort keys %expected_shape_contracts]),
    'Shape IDs differ from the six SHR-012 contracts'
);
if ($sticker_count) {
    assert_true($sticker_count >= 40, 'A published v1 sticker catalog must contain at least 40 entries');
    for my $category (qw(travel transport nature weather symbols)) {
        assert_true(
            ($sticker_count_by_category{$category} // 0) >= 6,
            "Sticker category $category must contain at least six entries"
        );
        assert_true(
            scalar(keys %{$sticker_tags_by_category{$category} // {}}) >= 3,
            "Sticker category $category must publish at least three distinct French tags"
        );
    }
}
if ($frame_count) {
    assert_true($frame_count == 6, 'A published v1 frame catalog must contain exactly six entries');
    assert_true(
        json_equal([sort keys %seen_frame_ids], [sort keys %expected_frame_ids]),
        'Decorative-frame IDs differ from SHR-011'
    );
}

my %expected_catalog_hashes;
for my $line (split /\n/, bytes(File::Spec->catfile($root, 'docs/catalog-checksums-v1.sha256'))) {
    next unless $line =~ /^([0-9a-f]{64})  (.+)$/;
    assert_true(!exists $expected_catalog_hashes{$2}, "Duplicate frozen checksum path $2");
    $expected_catalog_hashes{$2} = $1;
}
my @frozen_catalog_paths = (
    'layout-templates-v1.json',
    'catalog-resources-v1.json',
    'schema/catalog-resources-v1.schema.json',
    'catalog-renderer-contracts-v1.md',
    'golden/shape-masks-v1/shape-rectangle.pbm',
    'golden/shape-masks-v1/shape-roundedRectangle.pbm',
    'golden/shape-masks-v1/shape-circle.pbm',
    'golden/shape-masks-v1/shape-oval.pbm',
    'golden/shape-masks-v1/shape-heart.pbm',
    'golden/shape-masks-v1/shape-star.pbm'
);
assert_true(
    json_equal([sort keys %expected_catalog_hashes], [sort @frozen_catalog_paths]),
    'Frozen catalog checksum index has missing or unexpected paths'
);
for my $name (@frozen_catalog_paths) {
    my $actual = sha256_hex(bytes(File::Spec->catfile($root, 'docs', $name)));
    assert_true(($expected_catalog_hashes{$name} // '') eq $actual, "Frozen checksum mismatch for $name");
}

my $checksums = json('docs/examples/Minimal.photoalbum/checksums.json');
for my $entry (@{$checksums->{files}}) {
    my $path = File::Spec->catfile($root, 'docs/examples/Minimal.photoalbum', split('/', $entry->{relativePath}));
    my $data = bytes($path);
    assert_true(length($data) == $entry->{byteCount}, "Example byte count mismatch for $entry->{relativePath}");
    assert_true(sha256_hex($data) eq $entry->{sha256}, "Example SHA mismatch for $entry->{relativePath}");
}

print "Contracts OK: 32 templates, 3 backgrounds, 6 shapes, schemas and package fixture.\n";
