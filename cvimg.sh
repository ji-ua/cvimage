#!/bin/bash

function convert_image {
    if [ $1 == "svg" ]; then
        inkscape $2 --export-type=svg --export-filename=$3
    else
        convert "$2" "$3"
    fi
}

function parse_argument {
    args=("$@")
    
    if [ ${#args[@]} -eq 0 ]; then
        echo "Usage: 
        $0 [command] <input file or directory> <output directory>"
        echo "If <output directory> is not specified, the file is saved in the current directory."
        echo "Available Commands:
        -h              print this.
        -f [FORMAT]     specify format. [FORMAT]: png, jpg, pdf, svg, icns"
        exit 1
    fi

    case ${args[$1]} in
        -h)
            echo "Usage: 
            $0 [command] <input file or directory> <output directory>"
            echo "If <output directory> is not specified, the file is saved in the current directory."
            echo "Available Commands:
            -h              print this.
            -f [FORMAT]     specify format. [FORMAT]: png, jpg, pdf, svg, icns"
        exit 1
            ;;
        -f)
            if [ -z ${args[$2]} ]; then
                echo "did not specify format. "
                echo "-f [FORMAT]     specify format. [FORMAT]: png, jpg, pdf, svg, icns"
                exit 1
            fi
            ;;
        *)
            echo Invalid option: ${args[$1]}
            exit 1 
    esac
}

supported_formats=("png" "jpg" "pdf" "svg" "icns")

formats_string=$(IFS=, ; echo "${supported_formats[*]}")

parse_argument "$@"

output_format=$2
input=$3

if [ -z "$4" ]; then
    output_dir=$(pwd)
else
    output_dir=$4
fi

if ! [[ "$output_format" =~ ^(png|jpg|pdf|svg|icns)$ ]]; then
    echo "Unsupported output format: $output_format"
    echo "  -f [FORMAT]     specify format. [FORMAT]: png, jpg, pdf, svg, icns"
    exit 1
fi

mkdir -p "$output_dir"

if [ -d "$input" ]; then
    for file in "$input"/*; do
        if [ -f "$file" ]; then
            output_file="$output_dir/$(basename "$file" | cut -f 1 -d .).$output_format"

            convert_image "$output_format" "$file" "$output_file"
        fi
    done
elif [ -f "$input" ]; then
    output_file="$output_dir/$(basename "$input" | cut -f 1 -d .).$output_format"

    convert_image "$output_format" "$input" "$output_file"
else
    echo "Invalid input: $input"
    exit 1
fi
