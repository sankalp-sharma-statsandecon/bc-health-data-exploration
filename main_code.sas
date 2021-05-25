PROC IMPORT DATAFILE = "C:\Users\sanka\OneDrive - Kent State University\Econ 24\REQ73467_ECON24_Assignment_Q4_Datafile.csv"
	DBMS = CSV
	OUT = df;
	GETNAMES = YES;
RUN;

PROC SQL;
	CREATE TABLE working AS
	SELECT 
		Practitioner_ID AS prac
		,Virtual_Flag__0___In__person__1 AS v
		,sum(coalesce(Number_of_Distinct_Patient_Visit,0)) AS Number_of_Distinct_Patient_Visit
	FROM df
	WHERE Number_of_Distinct_Patient_Visit > 10
	GROUP BY
		prac 
		,v
;
QUIT;

PROC PRINT data=working (obs=20);
RUN;
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
PROC PRINT data=WORK.df_client2;
RUN;

PROC SQL;
	CREATE TABLE df_pracf AS
	SELECT 
		startdate Format = date9.
			,prac_id, prac_chsa, prac_status 
	FROM df_prac
	/*Start date is "after sept 2020"*/
	WHERE (prac_status = 'A' & startdate >= '01OCT2020'd & prac_chsa = 8525) OR 
		  (prac_status = 'A' & startdate >= '01OCT2020'd & prac_chsa = 8526); 
QUIT;

PROC SQL;
	/*CREATE TABLE df_clientf AS*/
	SELECT 
		servdt Format = date9.
			,Clnt_id, Clnt_chsa, Clmnum, Prac_id
	FROM df_client
	/*Start date is "after sept 2020"*/
	WHERE (servdt >= '01MAY2020'd & Clnt_chsa = 8525) OR 
		  (servdt >= '01MAY2020'd & Clnt_chsa = 8526); 
QUIT;

PROC SQL;
	SELECT input(put(servdt1),8.) as date1 Format = , prac_id
	FROM df_client2
	/*WHERE date1 BETWEEN '20190401'd AND '20190630'd*/
; 
QUIT;

PROC SQL;
	/*Prepare table*/
	CREATE TABLE finalanswer AS
	SELECT  
			x.startdate FORMAT = date9. AS StartDate
			,y.servdt FORMAT = date9. AS ServeDate /*Rename column names for final debate*/
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
	VAR StartDate ServeDate Practitioner Status Client_id Client_number;
	TITLE "List of Unique Patients Visiting Active Practitioners After Sep 2020";
	FOOTNOTE "*A is Active, I is Inactive";
RUN;

PROC SQL;
	TITLE "Grouped by Practitioner";
	FOOTNOTE "";
	SELECT count(Practitioner) as Practitioner
	FROM finalanswer
	GROUP BY Practitioner;
QUIT;

PROC SQL;
	SELECT
		INPUT(PUTservdt1 FORMAT = 
;
QUIT;

PROC SQL;
	CREATE TABLE main AS
	SELECT *
		, INPUT(PUT(servdt1,8.),yymmdd8.) AS date_num FORMAT = date9.
	FROM df_client2 
	;
QUIT;

PROC SQL;
	CREATE TABLE main AS
	SELECT *
		, INPUT(PUT(servdt1,8.),yymmdd8.) AS date_num FORMAT = date9.
	FROM df_client2; 
	SELECT *
	FROM main
	WHERE date_num BETWEEN '01OCT2020'd and '31DEC2020'd
	GROUP BY date_num, prac_id;
QUIT;

/*This sequence prepares the date variable in date9. Note that the new table is saved as msp_claims*/
/*to_date function cannot be called in proc sql. See below:*/
