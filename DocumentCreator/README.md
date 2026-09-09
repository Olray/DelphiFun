# DocumentCreator

A very, very, VERY simple template system with limited functionality.

1. Add units `DocumentCreator` and `DCTypes`
2. Create a new TDocumentCreator object and pass the template string to the constructor.
3. Add any number of resolvers to the object
4. Get the result by calling asString() or WriteToFile()

## Features

- Placeholders are in Twig-format "{{ key }}"
- Placeholders can have a parameterless post-processing filter added: "{{ key|filtername }}"

## Resolvers

Resolvers are used to map keys to values. Three sample resolvers are included but they're extremely straightforward
to implement. Four Resolver samples are included and serve as an example for your own Resolvers:

- Resolver_Single maps one single key-value pair
- Resolver_Multiple accepts an "array of const" with an even number of parameters
- Resolver_Func defines a callback function of the following signature: `function(const Key : string): TResolveResponse;`
- Resolver_DMap allows use of a DMap object from the legacy "Delphi Container and Algorithm Library" (DeCAL)

Implementing a Resolver to e.g. map fields of a database table row is trivial.

## Filters

Filters are also extremely easy to implement (since they're parameterless) and a few nonsense filter examples can
be found in `Filter.Common.pas`

Filters can be added to an "autoregistration" list by passing a factory method to the RegisterFilterFactory procedure.
Every new instance of TDocumentCreator will automatically instantiate and add all registered filters to it's filter list.

## Errors

If a placeholder cannot be resolved it's added to a special list of unresolved placeholders. Call `TDocumentCreator.Success:Boolean` to see if all placeholders are successfully replaced with their values.
Get an enumerable list of unresolved keys by calling `function GetUnresolved: TArray<string>;`

A helper method for console applications can be called by `procedure ReportMissingPlaceholders;`

Unresolved placeholders are wrapped in '???'. TDocumentCreator **should not** raise Exceptions.

## Usage

See `Tests\MainTest.pas`

## Found A Bug?

Send me a Test function that triggers the bug and I'll fix it ASAP