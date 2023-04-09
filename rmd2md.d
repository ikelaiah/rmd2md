module rmd2md;

import std.algorithm;
import std.stdio;
import file = std.file;
import std.conv;
import std.regex;
import std.getopt;
import std.path;
import std.datetime;
import std.parallelism;
import std.range;

void main(string[] args)
{
    // Set variables for the main program
    string programName = "Rmd2md";

    // Setup Regex for capturing Rmd code snippet header
    Regex!char re = regex(r"`{3}\{r[a-zA-Z0-9= ]*\}", "g");

    // Set default values for the arguments
    string inputPath = file.getcwd();
    string fileEndsWith = ".Rmd";
    string outputPath = file.getcwd();

    // Set GetOpt variables
    auto helpInformation = getopt(
        args,
        "path|p", "Path of Rmd files. Default: current working directory.", &inputPath,
        "fext|e", "Extension of Rmd files. Default: `.Rmd`", &fileEndsWith,
        "fout|o", "Output folder to save the MD files. Default: current working directory.", &outputPath
    );

    if (helpInformation.helpWanted)
    {
        defaultGetoptPrinter("Rmd to Markdown (md) file converter.",
            helpInformation.options);
        return;
    }

    // is the path valid?
    if (!std.path.isValidPath(inputPath))
    {
        writeln(programName ~ ": invalid input path");
        return;
    }

    // is output path valid?
    if (!std.path.isValidPath(outputPath))
    {
        writeln(programName ~ ": invalid output path");
        return;
    }

    // is file extension valid?
    if (!startsWith(fileEndsWith, "."))
    {
        writeln(programName ~ ": invalid extension given");
        return;
    }

    writeln(programName ~ ": input directory is " ~ inputPath);
    writeln(programName ~ ": output directory is " ~ outputPath);
    writeln(programName ~ ": ---");

    // Get no files in specified inputPath variable with a specific extension
    auto rmdFiles_for_counting = file.dirEntries(inputPath, file.SpanMode.shallow)
        .filter!(f => f.isFile)
        .filter!(f => f.name.endsWith(fileEndsWith));

    writeln(programName ~ ": found - " ~ to!string(rmdFiles_for_counting.walkLength) ~ fileEndsWith ~ " file(s)");
    writeln(programName ~ ": ---");

    // Get start time
    auto stattime = Clock.currTime();

    // Process each Rmd file
    int fileWrittenCount = 0;

    // Get files in specified inputPath variable with a specific extension
    auto rmdFiles = file.dirEntries(inputPath, file.SpanMode.shallow)
        .filter!(f => f.isFile)
        .filter!(f => f.name.endsWith(fileEndsWith));

    foreach (file.DirEntry item; parallel(rmdFiles))
    {
        writeln(Clock.currTime().toISOExtString, ": processing " ~ item.name);

        try
        {
            // Read content as string
            string content = file.readText(item.name);
            // Replace ```{r} or ```{r option1=value} with ```R
            string modified = replaceAll(content, re, "```R");
            // Set the Markdown output file
            string outputFile = replaceAll(baseName(item.name), regex(r".Rmd"), ".md");
            // Build an output path, using output path and baseName(item.name)
            string outputFilenamePath = buildPath(outputPath, outputFile);
            // Save output Markdown file
            file.write(outputFilenamePath, modified);
            writeln(Clock.currTime().toISOExtString, ": written " ~ outputFilenamePath);
            // Increase counter to indicate number of files processed
            fileWrittenCount++;
        }
        catch (file.FileException e)
        {
            writeln(programName ~ ": " ~ e.msg);
        }
    }

    writeln(programName ~ ": ---");

    // Gett end clock
    auto endttime = Clock.currTime();
    auto duration = endttime - stattime;
    writeln(programName ~ ": duration - ", duration);

    // Console output a summary
    writeln(programName ~ ": written " ~ to!string(fileWrittenCount) ~ " file(s)");
}
