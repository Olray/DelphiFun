unit DCTypes;

interface
uses
  DCUtilities;

type
  TResolveResponse = Nullable<string>;

    // on Win64 the compiler fails to allocate the Result variable for function
    // types and calls TValueProvider with no way to return a value.
  TValueProvider = reference to function(const Key : string): TResolveResponse;

  IResolver = interface
  ['{EB0E415E-3E5E-4FB0-B269-473BF5B71D7D}']
    function Resolve(const Key: string): TResolveResponse;
  end;

  IFilter = interface
  ['{E8E0EAB2-74D7-4191-961D-02B45FC3698A}']
    function getName: string;
    function process(AString: string): string;
  end;

  IFilterRegistration = interface
  ['{7409F13D-B58D-4230-A81E-33D33B5BAE8A}']
    procedure AddFilter(AFilter: IFilter);
  end;

implementation

end.
