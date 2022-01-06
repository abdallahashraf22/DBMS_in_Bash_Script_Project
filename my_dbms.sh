#!/bin/bash

shopt -s extglob
export LC_COLLATE=C

# why is the database and table names always in double quotations?
# so if the user entered a name with a space in it, it gets handled

Red="\e[31m"
Green="\e[32m"
Yellow="\e[33m"
ENDCOLOR="\e[0m"

# to keep the list going (keeps it getting printed)
while true; do
    select choice in "Create DataBase" "List DataBases" "Connect to DataBase" "Drop DataBase" "Exit"; do
        case $REPLY in
        1)
            # want to create a database
            echo "======================================================="
            echo -e $Green"Available databases: "$ENDCOLOR
            ls ./databases/
            echo "======================================================="
            read -p "What's its name: " database_name
            # checks if it exists already
            if [ -d ./databases/"$database_name" ]; then
                echo -e $Yellow"Such database already exists."$ENDCOLOR
            else
                mkdir ./databases/"$database_name"
                echo -e $Green"Database created successfully: "$ENDCOLOR
            fi
            break
            ;;

        2)
            # listing databases
            echo "======================================================="
            echo -e $Green"Available databases: "$ENDCOLOR
            ls ./databases/
            echo "======================================================="
            break
            ;;

        3)
            # get into a database
            echo "======================================================="
            echo -e $Green"Available databases: "$ENDCOLOR
            ls ./databases/
            echo "======================================================="
            read -p "Which database to connect to: " database_name_connect
            if [ -d ./databases/"$database_name_connect" ]; then
                # it will take the database name with it running my_tables script with the database name as input
                source my_tables.sh "$database_name_connect"
            else
                echo -e $Yellow"No such database named $database_name_connect exists."$ENDCOLOR
            fi
            break
            ;;

        4)
            # dropping a database
            echo "======================================================="
            echo -e $Green"Available databases: "$ENDCOLOR
            ls ./databases/
            echo "======================================================="
            read -p -e "Which database to drop: " database_name_delete
            if [ -d ./databases/"$database_name_delete" ]; then
                read -p "Are you sure you want to delete the database $database_name_delete? Enter y or n: " choice
                case $choice in
                [Yy]*)
                    rm -r ./databases/"$database_name_delete"
                    echo -e $Red"Deleted."$ENDCOLOR
                    break
                    ;;
                [Nn]*)
                    echo -e $Green"Didn't delete."$ENDCOLOR
                    break
                    ;;
                *)
                    echo -e $Yellow"Invalid choice; Didn't delete."$ENDCOLOR
                    break
                    ;;
                esac
            else
                echo $Yellow"Such database doesn't exist."$ENDCOLOR
            fi
            break
            ;;

        5)
            # the only way to quit the while loop
            exit 0
            ;;
        *)
            # why did we break and made it a while true instead? after so many wrong inputs
            # you kindda forget what the options were, instead, we re-print the options each time
            # anything else entered
            echo -e $Yellow"Invalid input"$ENDCOLOR
            break
            ;;
        esac
    done
done
