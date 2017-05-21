# Immutable

```
$ perl6 -I. -MImmutable -e '
my $i = Immutable.new;
$i .= insert-entity: {"person/name" => "Fernando", "person/age" => 35}
my \fid = $i.eid;
$i .= insert-entity: {"person/name" => "Aline", "person/age" => 33, "relationship/husband" => fid, "person/surname" => "Anjos"}
my \aid = $i.eid;
$i .= add-attributes: fid, {"relationship/wife" => aid, "person/surname" => "Oliveira"};



say $i;
#.say for $i.cache[1]<person/age>.cache[1]<person/age>
'
2 | relationship/wife    |                         4 | 3
2 | person/surname       |                  Oliveira | 3
5 | transaction/instant  | Instant:1495377615.406995 | 3
5 | transaction/tid      |                         3 | 3
4 | person/name          |                     Aline | 2
4 | person/age           |                        33 | 2
4 | relationship/husband |                         2 | 2
4 | person/surname       |                     Anjos | 2
3 | transaction/instant  | Instant:1495377615.295209 | 2
3 | transaction/tid      |                         2 | 2
2 | person/name          |                  Fernando | 1
2 | person/age           |                        35 | 1
1 | transaction/instant  | Instant:1495377615.194188 | 1
1 | transaction/tid      |                         1 | 1
```
