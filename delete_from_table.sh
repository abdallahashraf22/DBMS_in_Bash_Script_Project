#!/bin/bash
shopt -s extglob
export LC_COLLATE=C

echo "======================================================="
echo -e $Green"Available tables: "$ENDCOLOR
ls ./databases/"$1"/
echo "======================================================="
read -p "Which table: " table_to_delete_from
if [ ! -f ./databases/"$1"/"$table_to_delete_from" ]; then
    echo -e $Yellow"Such table doesn't exist."$ENDCOLOR
    source ./my_tables.sh
fi
echo "======================================================="
echo -e $Green"The Available Columns: "$ENDCOLOR
echo -e $Green$(awk -F "\t:\t" 'NR==1 {print $0}' ./databases/"$1"/"$table_to_delete_from")$ENDCOLOR
echo "======================================================="
# make sure the entered name is valid
read -p "Which column do you want as a Condition: " Column_condition
while [[ $Column_condition != +([a-zA-Z0-9-()]) ]]; do
    read -p "Enter a valid column name: " Column_condition
done
#check for it
column_condition_exist=$(awk -F"\t:\t" 'NR==1 {for(i=1; i< NF; i++) if($i=="'$Column_condition'") print i}' ./databases/"$1"/"$table_to_delete_from")
while [ -z "$column_condition_exist" ]; do
    echo -e $Yellow"This column doesn't exist."$ENDCOLOR
    read -p "Which column do you want as a Condition: " Column_condition
    while [[ $Column_condition != +([a-zA-Z0-9-()]) ]]; do
        read -p "Enter a valid column name: " Column_condition
    done
    column_condition_exist=$(awk -F"\t:\t" 'NR==1 {for(i=1; i< NF; i++) if($i=="'$Column_condition'") print i}' ./databases/"$1"/"$table_to_delete_from")
done
# check for the condition value
read -p "Enter the Column Value: " Condition_value
while [[ $Condition_value != +([a-zA-Z0-9]) ]]; do
    read -p "Enter a valid value as condition: " Condition_value
done
Column_delete_number=$(awk -F "\t:\t" 'NR==1 {for(i = 1; i<NF; i++) if($i=="'$Column_condition'") print i}' ./databases/"$1"/"$table_to_delete_from")
# get all the rows that have that condition in that particular column
string_length=$(cut -d: -f$Column_delete_number ./databases/"$1"/"$table_to_delete_from" | grep -n "$Condition_value" | cut -d: -f1)
for ((i = 0, j = 0; i < ${#string_length}; i = i + 2, j++)); do
    # get one row
    string_column_number_delete=${string_length:$i:1}
    # get the integer number of the row
    typeset -i inetger_column_number_delete=${string_column_number_delete:0:1}
    # delete j , which indicates if i deleted a row before, cause we need to go -1 with each deleted one
    inetger_column_number_delete=$inetger_column_number_delete-$j
    sed -i "$inetger_column_number_delete d" ./databases/"$1"/"$table_to_delete_from"
done
echo -e $Red"Deleted record"$ENDCOLOR
source ./my_tables.sh
