#!/bin/bash

# Wait 60 seconds for SQL Server to start up by ensuring that 
# calling SQLCMD does not return an error code, which will ensure that sqlcmd is accessible
# and that system and user databases return "0" which means all databases are in an "online" state
# https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-databases-transact-sql?view=sql-server-2017 

DBSTATUS=1
ERRCODE=1
i=0

sleep 60;

while ( [ -z "$DBSTATUS" ] || [[ $DBSTATUS -ne 0 ]] ) && [[ $i -lt 600 ]] && [[ $ERRCODE -ne 0 ]]; do
	i=$i+1
	DBSTATUS=$(/opt/mssql-tools18/bin/sqlcmd -C -h -1 -t 1 -S $SQL_SERVER -U $USER -P $PASSWORD -d $DATABASE -Q "SET NOCOUNT ON; Select SUM(state) from sys.databases")
	ERRCODE=$?
	sleep 1;
done

echo $DBSTATUS
echo $ERRCODE

if [[ $DBSTATUS -ne 0 ]] && [[ $ERRCODE -ne 0 ]]; then 
	echo "SQL Server took more than 60 seconds to start up or one or more databases are not in an ONLINE state"
	exit 1;
fi

# Run the setup script to create the DB and the schema in the DB
uvicorn main:app --host 0.0.0.0 --port 8000

