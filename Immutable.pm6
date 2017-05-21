unit class Immutable;
my UInt $fid = 1;

has UInt $.next-eid  = 1;
has UInt $.next-tid  = 1;
has List $.list      = ();

has      $.index     = (Map.new, Map.new, Map.new, Map.new);

method !fact-line(\entity-id, \attribute, \value, \trans-id) {
	(entity-id, attribute, value, trans-id) but $fid++
}

method add-fact(List \fact, :$next-eid = $!next-eid, :$next-tid = $!next-tid, :$index = 0) {
	my \c = \(fact, :$next-eid, :$next-tid);
	my $e-index = %(|$!index[0], fact[0] => ($!index[0]{fact[0]} // Immutable.new).add-fact(|c, :index(1 +| $index)))
		unless $index +& 1;
	my $a-index = %(|$!index[1], fact[1] => ($!index[1]{fact[1]} // Immutable.new).add-fact(|c, :index(2 +| $index)))
		unless $index +& 2;
	my $v-index = %(|$!index[2], fact[2] => ($!index[2]{fact[2]} // Immutable.new).add-fact(|c, :index(4 +| $index)))
		unless $index +& 4;
	my $t-index = %(|$!index[3], fact[3] => ($!index[3]{fact[3]} // Immutable.new).add-fact(|c, :index(8 +| $index)))
		unless $index +& 8;

	my \new = self.new(
		:$next-eid,
		:$next-tid,
		:list(|$!list, fact),
	);
	new.clone:
		:index(
			$e-index // { fact[0] => new },
			$a-index // { fact[1] => new },
			$v-index // { fact[2] => new },
			$t-index // { fact[3] => new },
		),
	;
}

method create-entity(\attribute, \value, UInt \trans-id, UInt :$next-tid = $!next-tid) {
	my \fact = self!fact-line($!next-eid, attribute, value, trans-id);
	my \eid  = $!next-eid;
	$.add-fact(fact, :next-eid($!next-eid + 1), :$next-tid) but role {has $.eid = eid}
}

method new-fact(\entity-id, \attribute, \value, \trans-id) {
	$.add-fact(self!fact-line(entity-id, attribute, value, trans-id))
}

method create-trans {
	my $tid = $!next-tid;
	my $tmp = $.create-entity("transaction/tid", $tid, $tid, :next-tid($tid + 1));
	$tmp.new-fact($tmp.eid, "transaction/instant", now, $tid)
		but role {has $.tid = $tid}
	;
}

method add-attributes(\eid, %map, :$tid is copy) {
	my $tmp = self;
	without $tid {
		$tmp = $.create-trans;
		$tid = $tmp.tid;
	}
	for %map.kv -> $key, $value {
		$tmp .= new-fact: eid, $key, $value, $tid;
	}
	$tmp
}

method insert-entity(%map) {
	my $tid   = $!next-tid;
	my $tmp   = $.create-trans;
	my @pairs = %map.pairs;
	my $first = @pairs.shift;
	$tmp      = $tmp.create-entity: $first.key, $first.value, $tid;
	my \eid   = $tmp.eid;
	$tmp.add-attributes(eid, %@pairs, :$tid) but role {has $.tid = $tid; has $.eid = eid}
}

method !sizes {
	my @sizes[4];
	for @$.list -> @line {
		for ^@line -> $id {
			my \size = @line[$id].chars;
			@sizes[$id] = size max (@sizes[$id] // 0)
		}
	}
	@sizes;
}

method gist {
	my @sizes = self!sizes;
	$!list.map(-> @data {sprintf "% *s | % -*s | % *s | % *s", flat @sizes Z @data}).join: "\n"
}

method as-of(Instant $inst) {
	my $found = 0;
	my @list = gather for @$!list -> \line {
		$found = 1 if $found == 0 and line[1] eq "transaction/instant" and line[2] <= $inst; #>
		$found = 2 if $found == 1 and line[1] !~~ m{^"transaction/"};
		take line if $found == 2;
	}
	self.clone: :@list
}

method !match(@line, +@matches) {
	my $vars = Map.new;
	for ^@matches -> \i {
		if @matches[i].substr(0, 1) eq "?" {
			$vars = Map.new: %$vars, { @matches[i] => @line[i] };
			next
		}
		return if @matches[i] !eq @line[i]
	}
	$vars
}

#multi method query(:$find!, :$where!) {
#	my @results = do for @$where -> $w {
#		my $a = ();
#		for @$!list -> \line {
#			my $tmp := self!match(line, @$w);
#			$a = ($tmp, |@$a) if $tmp.defined;
#		}
#		$a
#	}
#	my @res = [X] @results;
#	my @ans = @res.grep: -> @items {
#		return True if @items == 1;
#		my %keys := [(&)] @items>>.keys;
#		[~~] @items.map({.{%keys.keys}:kv});
#	}
#	my @l = @ans.map: {.reduce: -> %a, %b {% = |%a, |%b}};
#
#	@l.map: *.{|$find}
#}

#multi method query(:$find!, List :$where!) {
#	my $a = ();
#	for @$!list -> \line {
#		my $tmp := self!match(line, @$where);
#		$a = ($tmp, |@$a) if $tmp.defined;
#	}
#	.say for @$a;
#	$a.map: *.{|$find}
#}


