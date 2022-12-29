# RMD2MD

I work with lots of Rmd files (Rmarkdown). Often, I need to collaborate with other dev who don't work with Rmd files.

So, I wrote a little D program that reads Rmd files from a path and converts each file to a Markdown file (and can rendered using general Markdown viewer without using RStudio).

## Installation

You must have a [D Language compiler](https://dlang.org/download.html). No other installation are needed.

## Input path

A input file should contains valid URLs separated by a new line. Examples are provided in the repo.

## Usage

Compile using a D lang compiler and run it using `-p <path of Rms files>`.

An example to convert Rmd to MD using the `dmd` compiler.  

```bash
$ dmd rmd2md.d
$ ./rmd2md.exe -p <path-to-Rmd-files>
```

Alternatively, if you have the dmd compiler installed, you can run this like a script using [`rdmd`](https://dlang.org/rdmd.html) tool.

For example.

```bash
$ rdmd ./rmd2md.d -p "C:\<path>\<to>\<Rmd-files>\"
```

## License

[MIT](https://choosealicense.com/licenses/mit/)