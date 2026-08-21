#!/usr/bin/env perl
use strict;
use warnings;
use Compress::Zlib qw(compress crc32 uncompress Z_BEST_COMPRESSION);
use File::Basename qw(dirname);
use File::Temp qw(tempfile);

sub usage {
    die "Usage:\n"
        . "  $0 --validate-only <source.png>\n"
        . "  $0 <source.png> <destination.png> [dimension-max, défaut 512]\n"
        . "  $0 <source.png> <destination.png> --trim-alpha <marge-pixels>\n"
        . "  $0 <source.png> <destination.png> --nine-slice <largeur> <hauteur>"
        . " <haut> <gauche> <bas> <droite> <fraction-destination>\n"
        . "  $0 <source.png> <destination.png> --fill-circle <x> <y> <rayon>"
        . " <rouge> <vert> <bleu> <alpha>\n";
}

my $validate_only = @ARGV == 2 && $ARGV[0] eq '--validate-only';
@ARGV == 2 || @ARGV == 3 || @ARGV == 4 || @ARGV == 10 or usage();
my ($source, $destination) = $validate_only
    ? ($ARGV[1], undef) : @ARGV[0, 1];
my $nine_slice = @ARGV == 10 && $ARGV[2] eq '--nine-slice';
my $fill_circle = @ARGV == 10 && $ARGV[2] eq '--fill-circle';
my $trim_alpha = @ARGV == 4 && $ARGV[2] eq '--trim-alpha';
my $trim_padding = $trim_alpha ? $ARGV[3] : undef;
my $maximum = @ARGV == 3 ? $ARGV[2] : 512;
my ($requested_width, $requested_height, $cap_top, $cap_left, $cap_bottom,
    $cap_right, $destination_fraction);
my ($circle_x, $circle_y, $circle_radius, @circle_rgba);
if ($nine_slice) {
    ($requested_width, $requested_height, $cap_top, $cap_left, $cap_bottom,
        $cap_right, $destination_fraction) = @ARGV[3 .. 9];
    die "Paramètres neuf zones invalides.\n"
        unless $requested_width =~ /^\d+$/ && $requested_width > 0
            && $requested_height =~ /^\d+$/ && $requested_height > 0
            && $cap_top =~ /^\d+$/ && $cap_left =~ /^\d+$/
            && $cap_bottom =~ /^\d+$/ && $cap_right =~ /^\d+$/
            && $destination_fraction =~ /^(?:0(?:\.\d+)?|1(?:\.0+)?)$/
            && $destination_fraction > 0 && $destination_fraction < 0.5;
} elsif ($fill_circle) {
    ($circle_x, $circle_y, $circle_radius, @circle_rgba) = @ARGV[3 .. 9];
    die "Paramètres de cercle invalides.\n"
        unless $circle_x =~ /^\d+$/ && $circle_y =~ /^\d+$/
            && $circle_radius =~ /^\d+$/ && $circle_radius > 0
            && @circle_rgba == 4
            && !grep { $_ !~ /^\d+$/ || $_ > 255 } @circle_rgba;
} elsif ($trim_alpha) {
    die "La marge de recadrage alpha doit être un entier positif ou nul.\n"
        unless $trim_padding =~ /^\d+$/;
} else {
    die "La dimension maximale doit être un entier positif.\n"
        unless $maximum =~ /^\d+$/ && $maximum > 0;
}

open my $input, '<:raw', $source or die "Lecture impossible de $source: $!\n";
local $/;
my $png = <$input>;
close $input;
die "$source n’est pas un PNG.\n" unless substr($png, 0, 8) eq "\x89PNG\r\n\x1a\n";

my ($width, $height, $bit_depth, $color_type, $compression, $filter, $interlace);
my $idat = '';
my $offset = 8;
while ($offset + 12 <= length($png)) {
    my $length = unpack('N', substr($png, $offset, 4));
    my $type = substr($png, $offset + 4, 4);
    my $data = substr($png, $offset + 8, $length);
    die "Chunk PNG tronqué dans $source.\n"
        if length($data) != $length || $offset + 12 + $length > length($png);
    if ($type eq 'IHDR') {
        ($width, $height, $bit_depth, $color_type, $compression, $filter, $interlace)
            = unpack('NNCCCCC', $data);
    } elsif ($type eq 'IDAT') {
        $idat .= $data;
    } elsif ($type eq 'IEND') {
        last;
    }
    $offset += 12 + $length;
}

die "$source doit être un PNG RGBA 8 bits non entrelacé.\n"
    unless defined($width) && $bit_depth == 8 && $color_type == 6
        && $compression == 0 && $filter == 0 && $interlace == 0;
my $inflated = uncompress($idat);
die "Décompression PNG impossible pour $source.\n" unless defined $inflated;
my $stride = $width * 4;
die "Taille de flux PNG incohérente pour $source.\n"
    unless length($inflated) == ($stride + 1) * $height;

sub paeth {
    my ($left, $up, $upper_left) = @_;
    my $prediction = $left + $up - $upper_left;
    my $left_distance = abs($prediction - $left);
    my $up_distance = abs($prediction - $up);
    my $diagonal_distance = abs($prediction - $upper_left);
    return $left if $left_distance <= $up_distance && $left_distance <= $diagonal_distance;
    return $up if $up_distance <= $diagonal_distance;
    return $upper_left;
}

my @rows;
my $previous = "\0" x $stride;
for my $y (0 .. $height - 1) {
    my $row_offset = $y * ($stride + 1);
    my $filter_type = ord(substr($inflated, $row_offset, 1));
    my $encoded = substr($inflated, $row_offset + 1, $stride);
    my @bytes = unpack('C*', $encoded);
    my @above = unpack('C*', $previous);
    for my $index (0 .. $#bytes) {
        my $left = $index >= 4 ? $bytes[$index - 4] : 0;
        my $up = $above[$index];
        my $upper_left = $index >= 4 ? $above[$index - 4] : 0;
        if ($filter_type == 1) {
            $bytes[$index] = ($bytes[$index] + $left) & 255;
        } elsif ($filter_type == 2) {
            $bytes[$index] = ($bytes[$index] + $up) & 255;
        } elsif ($filter_type == 3) {
            $bytes[$index] = ($bytes[$index] + int(($left + $up) / 2)) & 255;
        } elsif ($filter_type == 4) {
            $bytes[$index] = ($bytes[$index] + paeth($left, $up, $upper_left)) & 255;
        } elsif ($filter_type != 0) {
            die "Filtre PNG $filter_type non pris en charge dans $source.\n";
        }
    }
    my $decoded = pack('C*', @bytes);
    push @rows, $decoded;
    $previous = $decoded;
}

my ($minimum_alpha, $maximum_alpha) = (255, 0);
for my $row (@rows) {
    for (my $index = 3; $index < length($row); $index += 4) {
        my $alpha = ord(substr($row, $index, 1));
        $minimum_alpha = $alpha if $alpha < $minimum_alpha;
        $maximum_alpha = $alpha if $alpha > $maximum_alpha;
    }
}
die "$source ne contient aucun pixel transparent.\n" unless $minimum_alpha < 255;
die "$source est entièrement transparent.\n" unless $maximum_alpha > 0;
exit 0 if $validate_only;

if ($trim_alpha) {
    my ($minimum_x, $minimum_y, $maximum_x, $maximum_y)
        = ($width, $height, -1, -1);
    for my $y (0 .. $height - 1) {
        for my $x (0 .. $width - 1) {
            next unless ord(substr($rows[$y], $x * 4 + 3, 1)) > 8;
            $minimum_x = $x if $x < $minimum_x;
            $maximum_x = $x if $x > $maximum_x;
            $minimum_y = $y if $y < $minimum_y;
            $maximum_y = $y if $y > $maximum_y;
        }
    }
    die "$source ne contient aucun pixel visible à recadrer.\n"
        if $maximum_x < $minimum_x || $maximum_y < $minimum_y;
    $minimum_x = $minimum_x > $trim_padding ? $minimum_x - $trim_padding : 0;
    $minimum_y = $minimum_y > $trim_padding ? $minimum_y - $trim_padding : 0;
    $maximum_x = $maximum_x + $trim_padding < $width
        ? $maximum_x + $trim_padding : $width - 1;
    $maximum_y = $maximum_y + $trim_padding < $height
        ? $maximum_y + $trim_padding : $height - 1;
    my $cropped_width = $maximum_x - $minimum_x + 1;
    my $cropped_height = $maximum_y - $minimum_y + 1;
    @rows = map {
        substr($_, $minimum_x * 4, $cropped_width * 4)
    } @rows[$minimum_y .. $maximum_y];
    ($width, $height) = ($cropped_width, $cropped_height);
}

if ($fill_circle) {
    for my $y (0 .. $height - 1) {
        for my $x (0 .. $width - 1) {
            next if ($x - $circle_x) ** 2 + ($y - $circle_y) ** 2
                > $circle_radius ** 2;
            substr($rows[$y], $x * 4, 4, pack('C*', @circle_rgba));
        }
    }
}

my ($output_width, $output_height);
if ($nine_slice) {
    die "Les marges source neuf zones se chevauchent.\n"
        unless $cap_left + $cap_right < $width
            && $cap_top + $cap_bottom < $height;
    ($output_width, $output_height) = ($requested_width, $requested_height);
} else {
    my $scale = $maximum / ($width > $height ? $width : $height);
    $scale = 1 if $scale > 1;
    $output_width = int($width * $scale + 0.5);
    $output_height = int($height * $scale + 0.5);
}

sub source_coordinate {
    my ($destination_index, $destination_size, $source_size,
        $source_start_cap, $source_end_cap, $destination_cap_fraction) = @_;
    return ($destination_index + 0.5) * $source_size / $destination_size - 0.5
        unless defined $destination_cap_fraction;
    my $destination_start_cap = $destination_size * $destination_cap_fraction;
    my $destination_end_start = $destination_size - $destination_start_cap;
    my $sample = $destination_index + 0.5;
    if ($sample < $destination_start_cap) {
        return $sample * $source_start_cap / $destination_start_cap - 0.5;
    }
    if ($sample >= $destination_end_start) {
        return $source_size - $source_end_cap
            + ($sample - $destination_end_start) * $source_end_cap
                / $destination_start_cap - 0.5;
    }
    my $source_middle = $source_size - $source_start_cap - $source_end_cap;
    my $destination_middle = $destination_size - 2 * $destination_start_cap;
    return $source_start_cap
        + ($sample - $destination_start_cap) * $source_middle
            / $destination_middle - 0.5;
}

my $raw = '';
for my $y (0 .. $output_height - 1) {
    $raw .= "\0";
    my $source_y = source_coordinate(
        $y,
        $output_height,
        $height,
        $cap_top,
        $cap_bottom,
        $nine_slice ? $destination_fraction : undef
    );
    my $y0 = int($source_y);
    $y0 = 0 if $y0 < 0;
    my $y1 = $y0 + 1 < $height ? $y0 + 1 : $y0;
    my $fy = $source_y - $y0;
    $fy = 0 if $fy < 0;
    for my $x (0 .. $output_width - 1) {
        my $source_x = source_coordinate(
            $x,
            $output_width,
            $width,
            $cap_left,
            $cap_right,
            $nine_slice ? $destination_fraction : undef
        );
        my $x0 = int($source_x);
        $x0 = 0 if $x0 < 0;
        my $x1 = $x0 + 1 < $width ? $x0 + 1 : $x0;
        my $fx = $source_x - $x0;
        $fx = 0 if $fx < 0;
        for my $channel (0 .. 3) {
            my $top_left = ord(substr($rows[$y0], $x0 * 4 + $channel, 1));
            my $top_right = ord(substr($rows[$y0], $x1 * 4 + $channel, 1));
            my $bottom_left = ord(substr($rows[$y1], $x0 * 4 + $channel, 1));
            my $bottom_right = ord(substr($rows[$y1], $x1 * 4 + $channel, 1));
            my $top = $top_left + ($top_right - $top_left) * $fx;
            my $bottom = $bottom_left + ($bottom_right - $bottom_left) * $fx;
            my $value = int($top + ($bottom - $top) * $fy + 0.5);
            $raw .= chr($value);
        }
    }
}

sub chunk {
    my ($type, $data) = @_;
    return pack('N', length($data)) . $type . $data
        . pack('N', crc32($type . $data));
}

my $encoded = "\x89PNG\r\n\x1a\n";
$encoded .= chunk('IHDR', pack('NNCCCCC',
    $output_width, $output_height, 8, 6, 0, 0, 0
));
$encoded .= chunk('IDAT', compress($raw, Z_BEST_COMPRESSION));
$encoded .= chunk('IEND', '');

my ($output, $temporary_path) = tempfile(
    '.catalog-png-XXXXXX',
    DIR => dirname($destination),
    UNLINK => 0
);
binmode $output;
print {$output} $encoded or die "Écriture impossible de $temporary_path: $!\n";
close $output or die "Fermeture impossible de $temporary_path: $!\n";
rename $temporary_path, $destination
    or die "Publication impossible de $destination: $!\n";
print "$destination ${output_width}x${output_height} alpha=${minimum_alpha}...${maximum_alpha}\n";
