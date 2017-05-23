class Immutable {
	class Keywords {
		has Map %.data .= new;
		method FALLBACK($name) {
			die "$name does not exists" unless %!data{$name}:exists;
			%!data{$name}
		}
		multi method add($name, $val) {
			$.add($name.subst(/^ '.'/, "").split("."), $val)
		}

		multi method add([], $val) {
			$val
		}

		multi method add([$n, @name], $val) {
			%(
				|%!data, $n => (%!data{$n} // Keywords.new).add(@name, $val)
			)
		}
	}
	class Fact {
		my $id = 0;
		has $!id          = $id++;
		has $.entity;
		has $.attribute;
		has $.value;
		has $.transaction;

		method id       { $!id }
		method destruct { $!entity, $!attribute, $!value, $!transaction }
		method sizes    { |$.destruct.map: *.chars }

		multi method new(UInt $entity, UInt $attribute, Any $value, UInt $transaction) {
			self.new: :$entity:$attribute:$value:$transaction
		}
	}

	sub init-attr($id is rw, \name) {
		Fact.new: $id //= $++, 0, name, 0
	}

	has Fact @.facts = (
		init-attr(my $ident, "db/ident")          ,
		init-attr(my $val-t, "db/valueType")      ,
		init-attr(my $card , "db/cardinality")    ,
		init-attr(my $doc  , "db/doc")            ,
		init-attr(my $uniq , "db/unique")         ,
		init-attr(my $index, "db/index")          ,
		init-attr(my $ftext, "db/fulltext")       ,
		init-attr(my $is-co, "db/isComponent")    ,
		init-attr(my $no-hi, "db/noHistory")      ,

		# db/valueType
		init-attr(my $ref  ,"db.type/ref")        ,
		init-attr(my $str  ,"db.type/string")     ,
		init-attr(my $bool ,"db.type/boolean")    ,

		# db/cardinality
		init-attr(my $one  ,"db.cardinality/one") ,
		init-attr(my $many ,"db.cardinality/many"),

		# db/unique
		init-attr(my $u-val,"db.unique/value")    ,
		init-attr(my $u-id ,"db.unique/identity") ,

		# db/ident
		Fact.new($ident, $val-t, $str                                       , 0),
		Fact.new($ident, $card , $one                                       , 0),
		Fact.new($ident, $doc  , "specifies the unique name of an attribute", 0),
		Fact.new($ident, $uniq , $u-id                                      , 0),
		Fact.new($ident, $index, True                                       , 0),

		# db/valueType
		Fact.new($val-t, $val-t, $ref                                                                  , 0),
		Fact.new($val-t, $card , $one                                                                  , 0),
		Fact.new($val-t, $doc  , "specifies the type of value that can be associated with an attribute", 0),

		# db/cardinality
		Fact.new($card, $val-t, $ref                                                                                        , 0),
		Fact.new($card, $card , $one                                                                                        , 0),
		Fact.new($card, $doc  , "specifies whether an attribute associates a single value or a set of values with an entity", 0),

		# db/doc
		Fact.new($doc, $val-t, $str                              , 0),
		Fact.new($doc, $card , $one                              , 0),
		Fact.new($doc, $doc  , "specifies a documentation string", 0),
	);

	has Keywords $.keywords .= new;
	has Map      $.EVAT     .= new;

	method sizes {
		@ = @!facts
			.map({$[.sizes]})
			.reduce: -> @a, @b {
				(@a Z @b).map: -> ($a, $b) { $a max $b }
			}
		;
	}

	method create-keyword($name) {

	}

	method add-EVAT(Fact \fact) {
		my ($entity, $attribute, $value, $transaction) = fact.destruct;
		Map.new: %(
			|$!EVAT,
				$entity => Map.new: %(
					|$!EVAT{$entity},
						$value => Map.new: %(
							|$!EVAT{$entity}{$value},
								Map.new: {$attribute => $transaction}
						)
				)
		)
	}

	method gist  {
		$ = do for @!facts {
			sprintf "% *s | % -*s | % *s | % *s", flat @.sizes Z .destruct
		}.join: "\n"
	}
	method List  {@!facts.List}
	method Array {@!facts.Array}
	method Set   {$.Array.Set}
}
