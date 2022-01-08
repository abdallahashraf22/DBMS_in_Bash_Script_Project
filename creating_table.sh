#!/bin/bash
shopt -s extglob
export LC_COLLATE=C

echo "======================================================="
echo -e $Green"Available tables: "$ENDCOLOR
ls ./databases/"$1"/
echo "======================================================="
# making sure it has a valid name and that it doesn't already exists
read -p "What's its name: " table_name
while [[ $table_name != +([a-zA-Z0-9-()]) ]]; do
    read -p "Enter a valid table name: " table_name
done
if [ -f ./databases/"$1"/"$table_name" ]; then
    echo -e $Yellow"Such table already exists."$ENDCOLOR
else
    # create the file , with the datatypes' file
    touch ./databases/"$1"/"$table_name"
    touch ./databases/"$1"/".$table_name"
    read -p "How many columns: " columns_num
    # as long as it was a number bigger than 0 (the 0-9 regex already handles negative)
    while [[ $columns_num != +([0-9]) || "$columns_num" -eq "0" ]]; do
        read -p "Enter a valid number of columns: " columns_num
    done
    # go over each column
    for ((i = 0; i < "$columns_num"; i++)); do
        read -p "Enter column name: " column_name
        while [[ $column_name != +([a-zA-Z0-9-()]) ]]; do
            read -p "Enter a valid column name: " column_name
        done
        does_the_column_exist=$(grep -w "$column_name" ./databases/"$1"/"$table_name")
        while [[ $column_name != +([a-zA-Z0-9-()]) || ! -z $does_the_column_exist ]]; do
            read -p "Enter valid column name: " column_name
            does_the_column_exist=$(grep -w "$column_name" ./databases/"$1"/"$table_name")
        done
        # put the column in the file
        echo -en "$column_name\t:\t" >>./databases/"$1"/"$table_name"
        read -p "Enter column datatype [string/int]: " data_type
        # make sure the entered type is either int or string
        while [[ "$data_type" != *(int)*(string) || -z "$data_type" ]]; do
            echo -e $Red"Invalid datatype;"$ENDCOLOR
            read -p "Enter column datatype [string/int]: " data_type
        done
        # write the data type
        echo -en "$data_type\t:\t" >>./databases/"$1"/".$table_name"
    done
    # do a new line
    echo -en "\n" >>./databases/"$1"/".$table_name"
    # ask which column to make the primary key, only one column can be pk
    echo -en "\n" >>./databases/"$1"/"$table_name"
    read -p "Which column do you want as primary key: " primary_col
    while [[ $primary_col != +([a-zA-Z0-9-()]) ]]; do
        read -p "Enter a valid column name: " primary_col
    done
    # see if that column actually exists (if column_exists is empty, then it doesn't)
    column_exists=$(awk -F"\t:\t" 'NR==1 {for(i=1; i< NF; i++) if($i=="'$primary_col'") print i}' ./databases/"$1"/"$table_name")
    while [[ -z "$column_exists" ]]; do
        echo -e $Yellow"This column doesn't exist."$ENDCOLOR
        read -p "Which column do you want as primary key: " primary
        column_exists=$(awk -F"\t:\t" 'NR==1 {for(i=1; i< NF; i++) if($i=="'$primary_col'") print i}' ./databases/"$1"/"$table_name")
    done
    # read the file, add (pk) next to the column, replace the og file with the same name
    sed "s/"$primary_col"/"$primary_col"(pk)/g" ./databases/"$1"/"$table_name" >./table16
    rm ./databases/"$1"/"$table_name"
    mv table16 ./databases/"$1"/"$table_name"
fi
echo -e $Green"Created successfully"$ENDCOLOR
source my_tables.sh
