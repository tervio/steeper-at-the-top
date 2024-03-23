Replication package for **Bernt Bratsberg, Ole Rogeberg, and Marko Terviö:  
"Steeper at the Top: Cognitive Ability and Earnings in Finland and Norway"**  
European Sociology Review (2024)  
[doi.org/10.1093/esr/jcae020](https://doi.org/10.1093/esr/jcae020)

Public data
-----------

[Input/Finland/](Input/Finland/) and [Input/Norway/](Input/Norway/) contain the public tables in dta format. These data are needed to make the publication figures. These folders also contain summary statistics of the individual level data in xlsx format.

Code that uses public data
---------------------------

This directory contains the Stata codes needed to produce the publication figures.

Run main.do from the [Code/](Code/) directory

It uses as inputs the public data at [Input/](Input/) directory and saves the output in .pdf and .jpg format at [Output/](Output/).  

The code was run with Stata 18. Marko Terviö (Aalto University) 2024-03-14. 

Individual level data (not included in the replication package)
---------------------------------------------------------------

The individual level data is confidential and access in each country requires a permit from the country's statistical authority. In the case of Finland, the conscript test score data requires also a separate permit from the Finnish Defense Forces (although this data is also accessible at Statistics Finland).

Code that uses individual level data
------------------------------------

[CountryCode/Finland/](CountryCode/Finland/) and [CountryCode/Norway](CountryCode/Norway/) contain the codes used to process the original individual level data. These codes produced the public data tables at [Input/Finland/](Input/Finland/)and [Input/Norway/](Input/Norway/) respectively. See the readme-files in these directories for more information.
