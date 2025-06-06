* Encoding: UTF-8.

*Analyze Participants' average age using frequencies:

FREQUENCIES VARIABLES=age
  /STATISTICS=STDDEV VARIANCE MEAN MEDIAN MODE
  /ORDER=ANALYSIS.

*Reliability for reappraisal to see if all the items in the questionnaire are related to each other:

RELIABILITY
  /VARIABLES=reappraise1 reappraise2 reappraise3 reappraise4 reappraise5 reappraise6
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.

*Reliability for health anxiety:

RELIABILITY
  /VARIABLES=shai_1 shai_2 shai_3 shai_4 shai_5 shai_6
  /SCALE('ALL VARIABLES') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE
  /SUMMARY=TOTAL.


*Calculate the mean for health anxiety measures:

DATASET ACTIVATE DataSet1.
COMPUTE shai_mean=MEAN(shai_1,shai_2,shai_3,shai_4,shai_5,shai_6).
EXECUTE.

*Calculate the mean for reapprasial measures:

COMPUTE reappraise_mean=MEAN(reappraise1,reappraise2,reappraise3,reappraise4,reappraise5,
    reappraise6).
EXECUTE.

*Calculate the total exposure to health related content
DATASET ACTIVATE DataSet1.
COMPUTE Exposure=healthmediadays * healthmediamin.
EXECUTE.


*Conducting moderation analysis:

process y = shai_mean / x = Exposure / w = reappraise_mean / model = 1 / center = 1 / intprobe = 1 /
moments = 1 / longname = 1.
process y = PE_mean / x = savor_mc / w = cedmi_mc / model = 1 / center = 1 / intprobe = 1 / moments = 1
/ longname = 1.

*Calculate the frequency for exposure to health related content, health anxiety, and reapprasial:

DATASET ACTIVATE DataSet1.
FREQUENCIES VARIABLES=shai_mean reappraise_mean Exposure
  /STATISTICS=STDDEV VARIANCE MEAN MEDIAN MODE
  /ORDER=ANALYSIS.


* Chart Builder for Correlations (Pearson’s r):

GGRAPH
  /GRAPHDATASET NAME="graphdataset" VARIABLES=Exposure shai_mean MISSING=LISTWISE REPORTMISSING=NO
  /GRAPHSPEC SOURCE=INLINE
  /FITLINE TOTAL=NO SUBGROUP=NO.
BEGIN GPL
  GUIDE: axis(dim(1), label("Exposure"))
  GUIDE: axis(dim(2), label("shai_mean"))
  GUIDE: text.title(label("Scatter Plot of shai_mean by Exposure"))
  ELEMENT: point(position(Exposure*shai_mean))
END GPL.

*Calculating Correlations between exposure and health anxiety. Also, I include reapprasial just to see if there is an effect:
  
CORRELATIONS
  /VARIABLES=Exposure shai_mean reappraise_mean
  /PRINT=TWOTAIL NOSIG FULL
  /CI CILEVEL(95)
  /MISSING=PAIRWISE.


*Conducting racial-ethnic and sexual identity variables
* Encoding: UTF-8.

/* The syntax below can help you make sense of the racial-ethnic identity and sexual identity variables that are measured as...
/* they are "check all that apply" and spread across multiple columns. Please note that the syntax is imperfect and may need to be...
/* adapted for your particular hypotheses, sample data you ended up with, etc. Please ask Dr. L for help when you are unsure!


/********************************************************************************************************************************************.
/* RACIAL-ETHNIC IDENTITY.
/********************************************************************************************************************************************.

/* Counts the number of times a participant checked a racial-ethnic identity box (excluding the "not listed here" and "prefer not to answer" options).
COMPUTE num_racecat=SUM(raceeth_1, raceeth_2, raceeth_3, raceeth_4, raceeth_5, raceeth_6, 
    raceeth_7, raceeth_8, raceeth_9).
VARIABLE LABELS num_racecat "Number of racial-ethnic identities indicated".
EXECUTE.

/* Requests a frequency breakdown for the number of participants reporting 1 or more than 1 racial-ethnic identity.
FREQUENCIES VARIABLES=num_racecat
  /ORDER=ANALYSIS.

/* Requests a frequency breakdown for each racial-ethnic identity category. Keep in mind that Ps can belong to more than one category.
FREQUENCIES VARIABLES=raceeth_1 raceeth_2 raceeth_3 raceeth_4 raceeth_5 raceeth_6 raceeth_7 raceeth_8 raceeth_9 raceeth_10 raceeth_11
  /ORDER=ANALYSIS.

/* Creates a new variable (called raceeth_describe) that maintains as many categories as possible. 
/* Except for the bi/multiracial group, all others could be considered "monoracial" in that they only checked one racial-ethnic-cultural identity.
/* May not be appropriate for use in an analysis. But can be used to describe your sample.
IF num_racecat = 1 AND raceeth_1 = 1 raceeth_describe = 1.
IF num_racecat = 1 AND raceeth_2 = 1 raceeth_describe = 2.
IF num_racecat = 1 AND raceeth_3 = 1 raceeth_describe = 3.
IF num_racecat = 1 AND raceeth_4 = 1 raceeth_describe = 4.
IF num_racecat = 1 AND raceeth_5 = 1 raceeth_describe = 5.
IF num_racecat = 1 AND raceeth_6 = 1 raceeth_describe = 6.
IF num_racecat = 1 AND raceeth_7 = 1 raceeth_describe = 7.
IF num_racecat = 1 AND raceeth_8 = 1 raceeth_describe = 8.
IF num_racecat = 1 AND raceeth_9 = 1 raceeth_describe = 9.
IF num_racecat = 1 AND raceeth_10 = 1 raceeth_describe = 10.
IF raceeth_11 = 1 raceeth_describe = 11.
IF num_racecat > 1 raceeth_describe = 12.
VARIABLE LABELS raceeth_describe "Participant's racial-ethnic identity (many categories retained)".
VALUE LABELS
raceeth_describe
1 "Black"
2 "East Asian"
3 "White"
4 "Latinx"
5 "MENA"
6 "Native American"
7 "Pacific Islander"
8 "South Asian"
9 "Southeast Asian"
10 "Other"
11 "Prefer not to answer"
12 "Bi/multiracial".
EXECUTE.

/* Requests a frequency breakdown for this new variable.
FREQUENCIES VARIABLES=raceeth_describe
  /ORDER=ANALYSIS.

/* From here, especially if racial-ethnic identity is a variable in your analyses (relevant to a hypothesis), you may want to condense the categories further.
/* Here is one example of that. May not be appropriate for your sample, so use your own best judgment in adapting this syntax.
    /* Note that this creates a nominal or categorical variable with (potentially) six levels.
   /* Note, too, how much variability and nuance we are losing in this process. Be mindful about whether this is an appropriate choice and whatever conclusions you draw.
RECODE raceeth_describe (1 = 1) (2 = 2) (3 = 3) (4 = 4) (5 = 5) (6 = 5) (7 = 2) (8 = 2) (9 = 2) (10 = 5) (11=5) (12=6) INTO raceeth_analysis.
VARIABLE LABELS raceeth_analysis "Participant's racial-ethnic identity (condensed for analysis)".
VALUE LABELS
raceeth_analysis
1 "Black"
2 "AAPI"
3 "White"
4 "Latinx"
5 "Other"
6 "Bi/multiracial".
EXECUTE.

/* Requests a frequency breakdown for this new variable.
FREQUENCIES VARIABLES=raceeth_analysis
  /ORDER=ANALYSIS.


/********************************************************************************************************************************************.
/* SEXUAL IDENTITY.
/********************************************************************************************************************************************.

/* Counts the number of times a participant checked a racial-ethnic identity box (excluding the "prefer not to answer" option).
COMPUTE num_sexcat=SUM(sex_ID_1, sex_ID_2, sex_ID_3, sex_ID_4, sex_ID_5, sex_ID_6, sex_ID_7, sex_ID_8).
VARIABLE LABELS num_sexcat "Number of sexual identities indicated".
EXECUTE.

/* Requests a frequency breakdown for the number of participants reporting 1 or more than 1 racial-ethnic identity.
FREQUENCIES VARIABLES=num_sexcat
  /ORDER=ANALYSIS.

/* Requests a frequency breakdown for each racial-ethnic identity category. Keep in mind that Ps can belong to more than one category.
/* Though participants can belong to more than one category, this may still be the best one for describing the sample.
    /* In which case, note in the text that the percentages sum to more than 100% because they could check all that apply.
FREQUENCIES VARIABLES=sex_ID_1 sex_ID_2 sex_ID_3 sex_ID_4 sex_ID_5 sex_ID_6 sex_ID_7 sex_ID_8 sex_ID_9 
  /ORDER=ANALYSIS.

/* Creates a new variable (called sexID_describe) that condenses into only three main categories: heterosexual, sexual minority, and prefer not to answer.
/* This choice may not be appropriate for your analyses, so use good judgment in adapting this syntax.
    /* Note that this creates a nominal or categorical variable with only three levels.
    /* The sexual minority category includes those who identified as asexual, bisexual, pansexual, gay/lesbian, queer, questioning, or other.
        /* Note that this category is about sexual identity only, as it does not include information about gender identity.
   /* Note, too, how much variability and nuance we are losing in this process. Be mindful about whether this is an appropriate choice and whatever conclusions you draw.
IF num_sexcat = 1 AND sex_ID_3 = 1 sexID_describe = 0.
IF num_sexcat > 1 AND sex_ID_3 = 1 sexID_describe = 1.
IF sex_ID_1 = 1 sexID_describe = 1.
IF sex_ID_2 = 1 sexID_describe = 1.
IF sex_ID_4 = 1 sexID_describe = 1.
IF sex_ID_5 = 1 sexID_describe = 1.
IF sex_ID_6 = 1 sexID_describe = 1.
IF sex_ID_7 = 1 sexID_describe = 1.
IF sex_ID_8 = 1 sexID_describe = 1.
IF sex_ID_9 = 1 sexID_describe = 2.
VARIABLE LABELS sexID_describe "Participant's sexual identity (condensed for description)".
VALUE LABELS
sexID_describe
0 "Heterosexual only"
1 "Sexual minority"
2 "Prefer not to answer".
EXECUTE.

/* Requests a frequency breakdown for this new variable.
FREQUENCIES VARIABLES=sexID_describe
  /ORDER=ANALYSIS.



