module rmd2md;

import std.algorithm;
import io = std.stdio;
import file = std.file;
import std.conv;
import std.regex;
import std.getopt;
import std.path;

void main(string[] args)
{
    // Set default values for the arguments
    string inputPath = file.getcwd();
    string fileEndsWith = ".Rmd";
    
    // Set variables for the main program
    string programName = "Rmd2md";
    int fileCount = 0;

    // Set GetOpt variables
    auto helpInformation = getopt(
        args,
        "path|p", "Path of Rmd files. Default: current working directory.", &inputPath,
        "fext|e", "Extension of Rmd files. Default: `.Rmd`", &fileEndsWith
    );

    if (helpInformation.helpWanted)
    {
        defaultGetoptPrinter("Rmd to Markdown (md) file converter.\nUsage: rmd2md [options]",
            helpInformation.options);
            return;
    }

    // is the path valid?
    if (!std.path.isValidPath(inputPath))
    {
        io.writeln(programName ~ ": invalid path");
        return;
    }

    // is file extension valid?
    if (!startsWith(fileEndsWith, "."))
    {
        io.writeln(programName ~ ": invalid extension given");
        return;
    }

    io.writeln(programName ~ ": working directory is " ~ inputPath);

    Regex!char re = regex(r"`{3}\{r[a-zA-Z0-9= ]*\}", "g");
    
    // Get files in specified inputPath variable with a specific extension
    auto rmdFiles = file.dirEntries(inputPath, file.SpanMode.shallow)
        .filter!(f => f.isFile)
        .filter!(f => f.name.endsWith(fileEndsWith));

    // Proces each Rmd file
    foreach (file.DirEntry item; rmdFiles)
    {
        io.writeln(programName ~ ": processing " ~ item.name);

        try
        {
            // Read content as string
            string content = file.readText(item.name);
            // Replace ```{r} or ```{r option1=value} with ```R
            string modified = replaceAll(content, re, "```R");
            // Set the Markdown output file
            string outputFile = replaceAll(item.name, regex(r".Rmd"), ".md");
            // Save output Markdown file
            file.write(outputFile, modified);
            // Increase counter to indicate number of files processed
            fileCount++;
        }
        catch (file.FileException e)
        {
            io.writeln(programName ~ ": " ~ e.msg);
        }
    }

    // Console output a summary
    io.writeln(programName ~ ": processed " ~ std.conv.text(fileCount) ~ " files");
}
