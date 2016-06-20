# Simple File Integrity Checker
Simple script to update and verify the checksums of filenames.

## Usage
`sfic.sh -f <filename> <options>`

#### Options
| Option | Description |
| :------ | :----------- |
| -f, --file \<filename\> | Filename with list of files/paths |
| -c, --check, --verify | Verify checksums |
| -u, --update | Update checksums |
| -h, --help | Show help |
| -V | Show program version and exit |

#### Filename example
Each line represent a filename or path (wildcards can be used).
Lines prefixed with `#` or `;` is excluded.
```bash
/etc/passwd

# MySQL related config files
/etc/mysql/*

# Apache2 config files
/etc/apache2/*
```

**NOTE:** 
> The path/file in the input file is passed directly to md5sum, stderr is sent to /dev/null so if the user does not have permission to view the files, all errors will be hidden.

> A file containing the filenames and checksums, will be placed in the same directory as the input file, and have a `.md5` extension.

## Requirements
Requires `md5sum` command.

#### Debian/ubuntu
`sudo apt-get install coreutils`

## Changelog
* v1.0 - Initial release

## License
This project is licensed under the terms of the [MIT license](./LICENSE.txt).
