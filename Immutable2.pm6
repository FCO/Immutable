class Immutable {
	class Fact {
		my $id = 0;
		has $!id          = $id++;
		has $.entity;
		has $.attribute;
		has $.value;
		has $.transaction;

		method id {$!id}

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

	method List  {@!facts.List}
	method Array {@!facts.Array}
	method Set   {self.Array.Set}
}
