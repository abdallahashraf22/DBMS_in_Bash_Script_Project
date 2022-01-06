#!/bin/bash

shopt -s extglob
export LC_COLLATE=C
echo "======================================================="
echo -e $Green"Available tables: "$ENDCOLOR
ls ./databases/"$1"/
echo "======================================================="
while true; do
    select choice in "Select all" "Select specific columns" "Select with where condition" "back"; do
        case $REPLY in
        1)
            # if the table exists, show it, nothing more nothing less.
            echo "======================================================="
            echo -e $Green"Available tables: "$ENDCOLOR
            ls ./databases/"$1"/
            echo "======================================================="
            read -p "Which table: " table_to_select
            if [ -f ./databases/"$1"/"$table_to_select" ]; then
                column -t -s"\t:\t" ./databases/"$1"/"$table_to_select"
            else
                echo -e $Yellow"Such table doesn't exist."$ENDCOLOR
            fi
            break
            ;;

        2)
            echo "======================================================="
            echo -e $Green"Available tables: "$ENDCOLOR
            ls ./databases/"$1"/
            echo "======================================================="
            read -p "Which table: " table_to_select
            if [ -f ./databases/"$1"/"$table_to_select" ]; then
                # if table exists, show the table's head (name of the columns)
                echo -e $Green$(awk -F "\t:\t" 'NR==1 {print $i}' ./databases/"$1"/"$table_to_select")$ENDCOLOR
                # how many columns to view
                typeset -i number_of_fields=$(awk -F "\t:\t" 'NR==1 {print NF}' ./databases/"$1"/"$table_to_select")
                number_of_fields=$number_of_fields-1
                # make sure it's a number, greater than zero, and less than the number of columns in the table
                read -p "Enter number of columns to view: " number_of_columns
                while [[ $number_of_columns != +([0-9]) || "$number_of_columns" -eq "0" || $number_of_columns -gt "$number_of_fields" ]]; do
                    read -p "Enter a valid number of columns: " number_of_columns
                done
                # initialize an int to increment the array, save all the columns into that array, cut them
                typeset -i element=0
                for ((i = 0; i < $number_of_columns; i++)); do
                    read -p "Enter column name: " column_name_selected
                    while [[ $column_name_selected != +([a-zA-Z0-9-()]) ]]; do
                        read -p "Enter a valid column name: " column_name_selected
                    done
                    # get the number of field of that column
                    field_number=$(awk -F "\t:\t" 'NR==1 {for(i = 1; i<NF; i++) if($i=="'$column_name_selected'") print i}' ./databases/"$1"/"$table_to_select")
                    # put them all in an array
                    if [ $field_number -gt 0 ]; then
                        arr[element]=$field_number
                        element=$element+1
                    else
                        echo -e $Yellow"This column doesn't exist"$ENDCOLOR
                    fi
                done
                # create a string of the array elements seperated by commas (even first one)
                sring=""
                for VAR in ${arr[@]}; do
                    #echo -n $VAR
                    string=$string,$VAR
                done
                # echo ${string:1} # Sub-String
                # use indexes to remove the first comma, and show the number of fields
                cut -d: -f ${string:1} ./databases/"$1"/"$table_to_select"
            else
                echo -e $Yellow"Such table doesn't exist."$ENDCOLOR
            fi
            break
            ;;

        3)
            #####################################################################################
            echo "======================================================="
            echo -e $Green"Available tables: "$ENDCOLOR
            ls ./databases/"$1"/
            echo "======================================================="
            read -p "Which table: " table_to_select
            if [ -f ./databases/"$1"/"$table_to_select" ]; then
                echo -e $Green"Available columns: "$ENDCOLOR
                echo $(awk -F "\t:\t" 'NR==1 {print $i}' ./databases/"$1"/"$table_to_select")
                # get the column we want as condition
                read -p "Which column do you want as a condition: " select_column_condition_ww
                while [[ $select_column_condition_ww != +([a-zA-Z0-9-()]) ]]; do
                    read -p "Enter a valid column name as a condition: " select_column_condition_ww
                done
                # get its number or if it even exists in that table
                select_column_condition_ww_exist=$(awk -F"\t:\t" 'NR==1 {for(i=1; i< NF; i++) if($i=="'$select_column_condition_ww'") print i}' ./databases/"$1"/"$table_to_select")
                while [ -z "$select_column_condition_ww_exist" ]; do
                    echo -e $Yellow"This column doesn't exist."$ENDCOLOR
                    read -p "Which column do you want as a condition: " select_column_condition_ww
                    while [[ $select_column_condition_ww != +([a-zA-Z0-9-()]) ]]; do
                        read -p "Enter a valid column name as a condition: " select_column_condition_ww
                    done
                    select_column_condition_ww_exist=$(awk -F"\t:\t" 'NR==1 {for(i=1; i< NF; i++) if($i=="'$select_column_condition_ww'") print i}' ./databases/"$1"/"$table_to_select")
                done
                # get the update value
                read -p "Enter the condition column value: " condition_update_value
                rows_numbers=$(cut -d: -f"$select_column_condition_ww_exist" ./databases/"$1"/"$table_to_select" | grep -n -w "$condition_update_value" | cut -d: -f1)
                # print the head of the file
                awk -F"\t:\t" 'NR=="1" {print $0}' ./databases/"$1"/"$table_to_select" | column -t -s"\t:\t"
                for ((i = 0; i < ${#rows_numbers}; i += 2)); do
                    # print all the rows
                    awk -F"\t:\t" 'NR=="'${rows_numbers:$i:1}'" {print $0}' ./databases/"$1"/"$table_to_select" | column -t -s"\t:\t"
                done
            else
                echo -e $Yellow"Such table doesn't exist"$ENDCOLOR
            fi
            #####################################################################################
            break
            ;;

        4)
            # go back to the previous menu (luckily the variable still get carried over {same shell})
            source my_tables.sh "$database_name_connect"
            break
            ;;
        esac
    done
done
