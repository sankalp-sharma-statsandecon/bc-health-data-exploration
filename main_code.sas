PROC IMPORT DATAFILE = "C:\Users\sanka\OneDrive - Kent State University\Econ 24\SAS code\prac_detail.csv"
	DBMS = CSV
	OUT = df_prac;
	GETNAMES = YES;
RUN;
PROC IMPORT DATAFILE = "C:\Users\sanka\OneDrive - Kent State University\Econ 24\SAS code\client_detail.csv"
	DBMS = CSV
	OUT = df_client;
	GETNAMES = YES;
RUN;
PROC SQL;
	/*Prepare table*/
	CREATE TABLE finalanswer AS
	SELECT  
		x.startdate FORMAT = date9.
		,y.servdt FORMAT = date9. AS ServeDate /*Rename column names*/
		,x.prac_id AS Practitioner 
		,x.prac_status AS Status
		,y.Clnt_id AS Client_id
		,y.Clmnum AS Client_number
	FROM 
		df_prac AS x
		,df_client AS y
	WHERE 
		/*Match and merge the two tables*/
		(y.prac_id = x.prac_id)
	AND
	/*Filter according to requisite conditions, active status, date after Sept 2020, prac_chsa*/
		((x.prac_status = 'A' & x.startdate >= '01OCT2020'd & x.prac_chsa = 8525) OR 
		 (x.prac_status = 'A' & x.startdate >= '01OCT2020'd & x.prac_chsa = 8526))
	AND
		((y.servdt >= '01OCT2020'd & y.Clnt_chsa = 8525) OR 
		 (y.servdt >= '01OCT2020'd & y.Clnt_chsa = 8526))
	;
QUIT;

PROC PRINT data=WORK.finalanswer; 
VAR ServeDate Practitioner Status Client_id Client_number;
	TITLE "List of Unique Patients Visiting Active Practitioners After Sep 2020";
	FOOTNOTE "*A is Active, I is Inactive";
RUN;
/*
List of Unique Patients Visiting Active Practitioners After Sep 2020

Obs	StartDate	ServeDate	Practitioner	Status	Client_id	Client_number
1	01OCT2020	05DEC2020	34897	A	G	109242
2	01NOV2020	04OCT2020	84513	A	J	109245
3	01NOV2020	16NOV2020	84513	A	K	109246
4	01NOV2020	24DEC2020	84513	A	A	109249
*/
*A is Active, I is Inactive

*The table shows that there are two unique practitioners (ID: 34897 and 84513) in the PCN area. With practitioner 34897 receiving one patient (client G) and 84513 receiving three (clients A,K and J). The Frequency table is provided below. 

PROC SQL;
	TITLE "Grouped by Practitioner";
	FOOTNOTE "";
	SELECT Practitioner, count(Practitioner) as Frequency
	FROM finalanswer
	GROUP BY Practitioner;
QUIT;

/*
Grouped by Practitioner

Practitioner	Frequency
34897	1
84513	3
*/
