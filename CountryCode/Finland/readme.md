Replication package for "the Finnish half" of the results in  
**Bernt Bratsberg, Ole Rogeberg, and Marko Terviö:  
"Steeper at the Top: Cognitive Ability and Earnings in Finland and Norway"**  
European Sociology Review (2024)  
[doi.org/10.1093/esr/jcae020](https://doi.org/10.1093/esr/jcae020)  

This directory contains code that requires access to the confidential individual level data at Statistics Finland (StatFin). The drive names and paths to raw data folders provided by StatFin may not be stable. First, modify the global path definitions at the top of main.do accordingly. Then just...

Run main.do using the code directory as the working directory.

The input consists of standard FOLK modules "Perus" (basic) and "Tulo" (incomes) and of a dataset of conscript test scores that the Finnish Defense Forces (FDF) has sent to StatFin. All of these modules are divided between many files and require preprocessing; the preprocessing code is also included (note it can be rather slow). 
The paths to FOLK modules are fixed at the StatFin server and are the same for all users who obtain access (as of 2024-03). The paths to the FDF data files may vary, as this is a customized dataset that StatFin delivers to a project-specific read-only drive. FDF data uses a different set of individual pseudo-ids than FOLK data; StatFin provides a crosswalk table between these two pseudo-ids as part of the customized dataset. 

The output is [the Finnish part of the public tables](../../Input/Finland/) for Bratsberg, Rogeberg, and Terviö (2024).  
The code also produces, as a side effect, preview figures of the "Finnish half" of the publication figures, and prints the results of various sanity checks to standard output. 

The code was run with Stata 18.  
Marko Terviö (Aalto University) 2024-03-06. 