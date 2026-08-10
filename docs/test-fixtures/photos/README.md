# Photos de test synthétiques

Ces images PNG ne contiennent aucune donnée personnelle. Elles sont générées
par `tools/generate_photo_fixture.c` pour rendre les contrôles de taille native,
de cadrage, d'orientation et de zoom reproductibles (`CAN-009`, `CRP-001` à
`CRP-007`, `PHO-005`). Les aplats, la bordure sombre et la croix centrale
permettent de repérer immédiatement une inversion, un recadrage ou un décalage.

| Fichier | Dimensions | SHA-256 | Usage principal |
|---|---:|---|---|
| `small-landscape-600x400.png` | 600 × 400 px | `407edaf04f5fd921e8e4bca7359d55e6d87b3f2876ebd99caead085a285a6ecc` | Vérifier qu'à `1×` une petite photo reste centrée à sa taille native avec le fond visible autour. |
| `medium-landscape-2400x1800.png` | 2 400 × 1 800 px | `08dff2054c238e1299214ef579407b880b3f01bf509c4b67d231555aaa6bc841` | Vérifier qu'à `0,5×` la photo remplit exactement un cadre canonique 1 200 × 900. |
| `large-portrait-4800x6000.png` | 4 800 × 6 000 px | `f3547f764f7eec40178bd1f3602863e0ed35bc6fe30777acde91b2f5d95903ca` | Vérifier la borne basse dynamique, notamment `0,5×` dans un cadre pleine page 2 400 × 3 000. |
| `square-1200x1200.png` | 1 200 × 1 200 px | `494a22dff3b8765d5e62ffca306434e314323c97a41e5108dbbc563c3bd4b360` | Vérifier rotation, retournement, déplacement et découpe rectangulaire. |

Régénération sous Linux :

```sh
cc -O2 tools/generate_photo_fixture.c /lib/x86_64-linux-gnu/libpng16.so.16 -lz -o /tmp/albumzh-generate-photo-fixture
/tmp/albumzh-generate-photo-fixture 600 400 docs/test-fixtures/photos/small-landscape-600x400.png
/tmp/albumzh-generate-photo-fixture 2400 1800 docs/test-fixtures/photos/medium-landscape-2400x1800.png
/tmp/albumzh-generate-photo-fixture 4800 6000 docs/test-fixtures/photos/large-portrait-4800x6000.png
/tmp/albumzh-generate-photo-fixture 1200 1200 docs/test-fixtures/photos/square-1200x1200.png
```
