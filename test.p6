use lib ".";
use Immutable;

my $i = Immutable.new;
$i .= insert-entity: {"person/name" => "Fernando", "person/age" => 35}
my \fid = $i.eid;
$i .= insert-entity: {"person/name" => "Aline", "person/age" => 33, "relationship/husband" => fid, "person/surname" => "Anjos"}
my \aid = $i.eid;
$i .= add-attributes: fid, {"relationship/wife" => aid, "person/surname" => "Oliveira"};



say $i;
.say for $i.index[1]<person/age>.index[1]<person/age>
