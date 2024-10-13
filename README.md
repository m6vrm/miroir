Single-header YAML schema validation library for C++.

Features
========

*   Support for custom and generic types
*   Support for type and value variants
*   No runtime dependencies (well, technically)

Designed to work with yaml-cpp (https://github.com/jbeder/yaml-cpp), but can be
used with any library for which the miroir::NodeAccessor template specialization
exists.

Requirements
============

*   C++20 compatible compiler

Usage
=====

```cpp
#define MIROIR_IMPLEMENTATION           // define once to instantiate
                                        // implementation
#define MIROIR_YAMLCPP_SPECIALIZATION   // define once to instantiate yaml-cpp
                                        // bindings
#include <miroir/miroir.hpp>
#include <yaml-cpp/yaml.h>

...

// load schema and create validator
auto schema = YAML::LoadFile("path/to/schema.yml");
auto validator = miroir::Validator<YAML::Node>(schema);

// validate yaml document
auto document = YAML::LoadFile("path/to/document.yml");
auto errors = validator.validate(document);

// print validation errors
for (const auto &error : errors) {
    std::cerr << error.description() << std::endl;
}
```

Built-in types
==============

NOTE: Quoted values are always represent a string.

    any         numeric     boolean
    map         num         bool
    list        integer     string
    scalar      int         str

Specification
=============

NOTE: Creating a miroir::Validator with invalid schema can lead to assertion
failures on Debug builds and undefined behavior or crashes on Release builds.

Settings
--------

Defines validation behavior and schema format. Optional.

```yml
settings:
    default_required: bool      # all fields are required unless otherwise
                                # specified, default: true
    ignore_attributes: bool     # ignore key attributes, default: false
    optional_tag: string        # tag to mark optional fields, default:
                                # "optional"
    required_tag: string        # tag to mark required fields, default:
                                # "required"
    embed_tag: string           # tag to mark embedded fields, default: "embed"
    variant_tag: string         # tag to mark value variants, default: "variant"
    key_type_prefix: char       # prefix to mark typed keys, default: "$"
    generic_brackets: char[2]   # generic type specifiers, default: "<>"
    generic_separator: char     # generic arguments separator, default: ";"
```

Types
-----

Custom types. Optional.

```yml
types:
    # types can be generic
    # note that there's no space next to generic arguments separator
    list<T>: [T]
    map<K;V>: { $K: V }
    bool_list: list<bool>           # same as [bool]
    string_map: map<string;string>  # same as { $string: string }

    # sequence with one type takes sequence of values of that type
    # following type takes sequence of integer values
    int_sequence: [int]

    # sequence of more than one type is a type variant
    # following type takes any string or bool value
    string_or_bool:
        - string
        - bool

    # !variant tag is used to define value variants
    # following type takes only specified values: red, green or blue
    color: !variant
        - red
        - green
        - blue

    # types can be compound
    car:
        # brand field is required and takes string value
        brand: string
        # color field is required and takes values: red, green or blue
        color: color
        # owner_id field is optional and takes integer value
        owner_id: !optional int

    # compound types can be embedded into each other
    # following type reuses fields from the car type
    self_driving_car:
        is_self_driving: bool
        # embed fields from the car type
        # name of the key is irrelevant but must be unique
        irrelevant_key_name: !embed car

    # keys also can be typed when prefixed with $
    # following type key takes values: red, gree or blue
    color_descriptions:
        $color: string
```

Document root
-------------

Represents document format. Required.

```yml
root:
    date: !optional string
    cars: [self_driving_car]
    colors: !embed color_descriptions
```

Contributing
============

Use cgen (https://github.com/m6vrm/cgen) to generate the CMakeLists.txt file.

    git clone --recurse-submodules https://github.com/m6vrm/miroir

    make format       # format source code
    make clean test   # run tests
    make check        # run static checks
    make clean asan   # run tests with address sanitizer
    make clean ubsan  # run tests with UB sanitizer
