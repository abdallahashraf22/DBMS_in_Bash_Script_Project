#!/bin/bash
shopt -s extglob
export LC_COLLATE=C

while true; do
    echo "======================================================="
    echo -e $Green"Available tables: "$ENDCOLOR
    ls ./databases/"$1"/
    echo "======================================================="
    select choice in "Create table" "List tables" "Drop table" "Insert into table" "Select from table" "Delete from table" "Update table" "Back"; do
        case $REPLY in
        1)
            # Creating table
            source ./creating_table.sh
            break
            ;;

        2)
            #listing the table at the beginning is already at the top of the while loop
            break
            ;;

        3)
            # dropping table (deleting both the file table and its corresponding datatype file)
            echo "======================================================="
            echo -e $Green"Available tables: "$ENDCOLOR
            ls ./databases/"$1"/
            echo "======================================================="
            read -p "Which table do you want to drop: " table_name_delete
            if [ -f ./databases/"$1"/"$table_name_delete" ]; then
                read -p "Are you sure you want to delete the table $table_name_delete? Enter y or n: " choice
                case $choice in
                [Yy])
                    rm ./databases/"$1"/"$table_name_delete"
                    rm ./databases/"$1"/".$table_name_delete"
                    echo -e $Red"Deleted"$ENDCOLOR
                    break
                    ;;
                [Nn])
                    echo -e $Green"Didn't delete."$ENDCOLOR
                    break
                    ;;
                *)
                    echo -e $Yellow"Invalid choice; didn't delete."$ENDCOLOR
                    break
                    ;;
                esac
            else
                echo -e $Yellow"No such table exists."$ENDCOLOR
            fi
            break
            ;;
        4)
            # go for the insertion (there we handle if the table doesn't exist)
            source ./insertion.sh
            ;;

        5)
            # go for the selection (there we handle if the table doesn't exist)
            source ./selecting_from_table.sh
            ;;
        6)
            # go for the selection (there we handle if the table doesn't exist)
            source ./delete_from_table.sh
            ;;
        7)
            # go for the selection (there we handle if the table doesn't exist)
            source ./updating_table.sh
            ;;
        8)
            # go back to the previous menu
            echo "======================================================="
            source my_dbms.sh
            ;;
        *)
            # any other input
            echo -e $Yellow"invalid input"$ENDCOLOR
            break
            ;;
        esac
    done
done
