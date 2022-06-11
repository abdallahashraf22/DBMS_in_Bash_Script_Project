#!/bin/bash
shopt -s extglob
export LC_COLLATE=C

echo "======================================================="
echo -e $Green"Available tables: "$ENDCOLOR
ls ./databases/"$1"/
echo "======================================================="
read -p "Which table: " table_to_insert
if [ ! -f ./databases/"$1"/"$table_to_insert" ]; then
    echo "Table doesn't exist."
    source ./my_tables.sh
fi
echo "======================================================="
echo -e $Green"The Available Columns: "$ENDCOLOR
echo -e $Green$(awk -F "\t:\t" 'NR==1 {print $0}' ./databases/"$1"/"$table_to_insert")$ENDCOLOR
echo "======================================================="
# get how many fields in the table
number_of_insertion_col=$(awk -F "\t:\t" 'NR==1 {print NF}' ./databases/"$1"/"$table_to_insert")
for ((j = 1; j < $number_of_insertion_col; j++)); do
    # know the number of column for the pk
    primary_key_field=$(awk -F"\t:\t" 'NR == 1 {for ( i=1; i < NF; i++ ) if( $i ~ /(pk)/) print i}' ./databases/"$1"/"$table_to_insert")
    #know the data type
    type_read=$(cut -d: -f$j ./databases/"$1"/".$table_to_insert" | head -n 1)
    echo "the datatype of this column is $type_read"
    # if it's an int
    if [ $type_read = "int" ]; then
        # get what is that column called
        name_column_field=$(awk -v test="$j" -F"\t:\t" 'NR==1 {print $test}' ./databases/"$1"/"$table_to_insert")
        read -p "Type value of column $name_column_field: " value_col
        if [ $j = $primary_key_field ]; then
            # know if that value repeated or not
            filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_insert" | grep -w $value_col)
            while ! [ -z "$filled_or_not" ]; do
                read -p "Repeated , Enter a primary key: " value_col
                filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_insert" | grep -w $value_col)
            done
        fi
        # only accept an int
        while [[ $value_col != +([0-9]) ]]; do
            echo -e $Red"This column is an int."$ENDCOLOR
            read -p "Enter an int: " value_col
            if [ $j = $primary_key_field ]; then
                filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_insert" | grep -w $value_col)
                while ! [ -z "$filled_or_not" ]; do
                    read -p "Repeated , Enter a primary key: " value_col
                    filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_insert" | grep -w $value_col)
                done
            fi
        done
    else
        # if it's a string
        name_column_field=$(awk -v test="$j" -F"\t:\t" 'NR==1 {print $test}' ./databases/"$1"/"$table_to_insert")
        read -p "Type value of column $name_column_field: " value_col
        if [ $j = $primary_key_field ]; then
            # know if that value repeated or not
            filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_insert" | grep -w $value_col)
            while ! [ -z "$filled_or_not" ]; do
                read -p "Repeated , Enter a primary key: " value_col
                filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_insert" | grep -w $value_col)
            done
        fi
        while [[ $value_col != +([a-zA-Z0-9\ ]) ]]; do
            echo -e $Red"This column is a string."$ENDCOLOR
            read -p "Enter a string: " value_col
            # and it's also the pk
            if [ $j = $primary_key_field ]; then
                filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_insert" | grep -w $value_col)
                while ! [ -z "$filled_or_not" ]; do
                    read -p "Repeated , Enter a primary key: " value_col
                    filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_insert" | grep -w $value_col)
                done
            fi
        done
    fi
    echo -en "$value_col\t:\t" >>./databases/"$1"/"$table_to_insert" # ~ Problem with ""
done
echo "" >>./databases/"$1"/"$table_to_insert"
echo -e $Green"Inserted record successfully"$ENDCOLOR
source ./my_tables.sh
