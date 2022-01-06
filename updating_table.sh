#!/bin/bash
shopt -s extglob
export LC_COLLATE=C

echo "======================================================="
echo -e $Green"Available tables: "$ENDCOLOR
ls ./databases/"$1"/
echo "======================================================="
read -p "Which table: " table_to_update
if [ ! -f ./databases/"$1"/"$table_to_update" ]; then
    echo -e $Yellow"Such table doesn't exist."$ENDCOLOR
    source ./my_tables.sh
fi
echo "======================================================="
echo -e $Green"The Available Columns: "$ENDCOLOR
echo -e $Green$(awk -F "\t:\t" 'NR==1 {print $0}' ./databases/"$1"/"$table_to_update")$ENDCOLOR
echo "======================================================="
# get name of the column to update , make sure it's valid name
read -p "Which column do you want to update: " Column_to_be_updated
while [[ $Column_to_be_updated != +([a-zA-Z0-9-()]) ]]; do
    read -p "Enter a valid column name: " Column_to_be_updated
done
# get the number of it
Column_to_be_updated_exist=$(awk -F"\t:\t" 'NR==1 {for(i=1; i< NF; i++) if($i=="'$Column_to_be_updated'") print i}' ./databases/"$1"/"$table_to_update")
while [ -z "$Column_to_be_updated_exist" ]; do
    echo -e $Yellow"This column doesn't exist."$ENDCOLOR
    read -p "Which column do you want to update: " Column_to_be_updated
    while [[ $Column_to_be_updated != +([a-zA-Z0-9-()]) ]]; do
        read -p "Enter a valid column name: " Column_to_be_updated
    done
    Column_to_be_updated_exist=$(awk -F"\t:\t" 'NR==1 {for(i=1; i< NF; i++) if($i=="'$Column_to_be_updated'") print i}' ./databases/"$1"/"$table_to_update")
done
# get name of the column that will be a condition , make sure it's valid name
read -p "Which column do you want as a Condition: " Column_update_condition
while [[ $Column_update_condition != +([a-zA-Z0-9-()]) ]]; do
    read -p "Enter a valid column name: " Column_update_condition
done
# get its number
Column_update_condition_exist=$(awk -F"\t:\t" 'NR==1 {for(i=1; i< NF; i++) if($i=="'$Column_update_condition'") print i}' ./databases/"$1"/"$table_to_update")
while [ -z "$Column_update_condition_exist" ]; do
    echo -e $Yellow"This column doesn't exist."$ENDCOLOR
    read -p "Which column do you want as a Condition: " Column_update_condition
    while [[ $Column_update_condition != +([a-zA-Z0-9-()]) ]]; do
        read -p "Enter a valid column name: " Column_update_condition
    done
    Column_update_condition_exist=$(awk -F"\t:\t" 'NR==1 {for(i=1; i< NF; i++) if($i=="'$Column_update_condition'") print i}' ./databases/"$1"/"$table_to_update")
done
# get the condition value, make sure it's valid
read -p "Enter the condition column value: " condition_update_value
while [[ $condition_update_value != +([a-zA-Z0-9]) ]]; do
    read -p "Enter a valid value: " condition_update_value
done
# get the number of rows that has that value in the condition column
string_length=$(cut -d: -f"$Column_update_condition_exist" ./databases/"$1"/"$table_to_update" | grep -n -w "$condition_update_value" | cut -d: -f1)
# go over those rows
for ((i = 0, j = 0; i < ${#string_length}; i = i + 2, j++)); do
    # get the first row
    string_row_number_update=${string_length:$i:1}
    # get its integer value
    typeset -i inetger_row_number_update=${string_row_number_update:0:1}
    # get that exact word from that column and that row intersection
    word=$(cut -d: -f"$Column_to_be_updated_exist" ./databases/"$1"/"$table_to_update" | head -"$inetger_row_number_update" | tail -1)
    ########################################################################################################
    # get the pk field
    primary_key_field=$(awk -F"\t:\t" 'NR == 1 {for ( i=1; i < NF; i++ ) if( $i ~ /(pk)/) print i}' ./databases/"$1"/"$table_to_update")
    # and get the type
    type_read=$(cut -d: -f$Column_to_be_updated_exist ./databases/"$1"/".$table_to_update" | head -n 1)
    #show it and go forward
    echo $type_read
    # if it's an int make sure it's a number
    if [ $type_read = "int" ]; then
        read -p "Type value of column $Column_to_be_updated: " update_value
        if [ $Column_to_be_updated_exist = $primary_key_field ]; then
            filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_update" | grep -w "$update_value")
            while ! [ -z "$filled_or_not" ]; do
                read -p "Enter a unique primary key: " update_value
                filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_update" | grep -w "$update_value")
            done
        fi
        while [[ "$update_value" != +([0-9]) ]]; do
            echo -e $Red"This column is an int."$ENDCOLOR
            read -p "Enter an int: " update_value
            if [ $Column_to_be_updated_exist = $primary_key_field ]; then
                filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_update" | grep -w "$update_value")
                echo "hello from if"
                while ! [ -z "$filled_or_not" ]; do
                    read -p "Enter a unique primary key: " update_value
                    filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_update" | grep -w "$update_value")
                done
            fi
        done
    else
        read -p "Type value of column $Column_to_be_updated: " update_value
        if [ $Column_to_be_updated_exist = $primary_key_field ]; then
            filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_update" | grep -w "$update_value")
            while ! [ -z "$filled_or_not" ]; do
                read -p "Enter a unique primary key: " update_value
                filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_update" | grep -w "$update_value")
            done
        fi
        while [[ "$update_value" != +([a-zA-Z0-9]) ]]; do
            echo -e $Red"This column is a string."$ENDCOLOR
            read -p "Enter a string: " update_value
            if [ $Column_to_be_updated_exist = $primary_key_field ]; then
                filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_update" | grep -w "$update_value")
                while ! [ -z "$filled_or_not" ]; do
                    read -p "Enter a unique primary key: " update_value
                    filled_or_not=$(cut -d: -f $primary_key_field ./databases/"$1"/"$table_to_update" | grep -w "$update_value")
                done
            fi
        done
    fi
    ########################################################################################################
    sed -i "$inetger_row_number_update s/$word/\t$update_value\t/g" ./databases/"$1"/"$table_to_update"
done

echo $Green"Updated successfully"$ENDCOLOR
source ./my_tables.sh
