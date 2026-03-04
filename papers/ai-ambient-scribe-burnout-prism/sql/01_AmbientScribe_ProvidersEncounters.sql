/*******************************************************************************
 * SQL CODE FOR MANUSCRIPT: "Implementation and evaluation of AI ambient scribes 
 *                           to reduced clinician burnout: a pragmatic mixed  
 *                           methods embedded randomized trial"
 *******************************************************************************
 * 
 * STUDY OVERVIEW
 * --------------
 *  This SQL script generates the analytical datasets for a randomized controlled
 *  trial evaluating the implementation of an ambient AI-powered clinical 
 *  documentation system (Abridge) in an academic medical center setting.
 * 
 * PRIMARY OBJECTIVES
 * ------------------
 *  1. Evaluate the impact of ambient AI documentation on provider workflows
 *  2. Assess changes in clinical encounter patterns and efficiency metrics
 *  3. Compare outcomes between intervention and control provider groups
 * 
 * DATA SOURCE
 * -----------
 *  Electronic Health Record System: Epic Clarity Database
 *  Database Schema: Epic Clarity relational database tables
 * 
 * OUTPUT DATASETS
 * ---------------
 *  1. Provider-Level Dataset (#providers):
 *      - Provider demographics, specialty information, and aggregated encounter counts
 *      - One record per participating provider
 * 
 *  2. Encounter-Level Dataset (#encounters):
 *      - Individual clinical encounter records with patient demographics
 *      - One record per eligible clinical encounter
 * 
 * KEY VARIABLES
 * -------------
 *  Provider Dataset:
 *      - USER_ID, PROV_ID, NPI: Provider identifiers
 *      - PROV_NAME, EMAIL: Provider contact information
 *      - LICENSE: Randomization group assignment ('License' = Intervention, 'Control' = Control)
 *      - LICENSE_ACTIVATED, LICENSE_REMOVED: Intervention assignment dates
 *      - PROV_TYPE, CLINICIAN_TITLE, PROVIDER_SPECIALTY: Provider characteristics
 *      - DEPARTMENT_NAME, CLINIC_NAME, CLINIC_TYPE: Practice setting
 *      - AGE_PILOT_COMMENCE, SEX, DOB: Provider demographics
 * 
 *  Encounter Dataset:
 *      - PAT_ENC_CSN_ID: Unique encounter identifier
 *      - PROV_ID: Treating provider identifier
 *      - ENCOUNTER_STATUS, ENCOUNTER_TYPE, VISIT_TYPE: Encounter characteristics
 *      - ENCOUNTER_DATE, DEPARTMENT_ID, DEPARTMENT_NAME: Encounter context
 *      - Patient demographics: AGE_AT_ENCOUNTER, SEX, GENDER_IDENTITY, RACE, 
 *        ETHNICITY, LANGUAGE, MARITAL_STATUS, INSURANCE_TYPE, ZIP
 *      - ABRIDGE_ENCOUNTER: Indicator for encounters with AI documentation
 * 
 * INCLUSION CRITERIA
 * ------------------
 * Providers:
 *  - Enrolled in the RCT at study launch or subsequently activated
 *  - Active clinical providers with eligible encounter types
 *  - Documented in @PARTICIPANTS table with randomization assignment
 * 
 * Encounters:
 *  - Occurred during study period (2025-01-13 to 2025-07-31)
 *  - With participating study providers
 *  - Eligible encounter and visit types as defined by study protocol
 *  - Complete required demographic and encounter data elements
 * 
 * REPRODUCIBILITY NOTES
 * ---------------------
 *  - Study parameters (dates, participant lists) are specified in DECLARE 
 *    statements at the beginning of the executable code
 *  - Encounter type eligibility criteria derived from study protocol documents
 *  - Provider specialties categorized into Surgical, Non-Surgical, and Primary Care
 *  - Dynamic license activation/removal tracking for intention-to-treat analyses
 * 
 * ETHICAL CONSIDERATIONS
 * ----------------------
 *  This study was approved by the Colorado Multiple Institutional Review Board (COMIRB).
 *  Data handling complies with HIPAA regulations and institutional data 
 *  governance policies. Patient and provider identifiers should be de-identified 
 *  prior to external data sharing.
 * 
 * LICENSE
 * -------
 *  This code is provided for academic and research purposes. Modifications and 
 *  redistribution are permitted with appropriate attribution.
 * 
 * CONTACT
 * -------
 *  For questions regarding this analysis code:
 *      Bryan Pfalzgraf, Lead Data Analyst
 *      Learning Health System Core
 *      University of Colorado Anschutz Medical Campus
 *      Email: bryan.pfalzgraf@cuanschutz.edu
 * 
 *  For questions regarding the clinical protocol:
 *      Dr. Anna Maw, MD
 *      ACCORDS Learning Health System Core 
 *      University of Colorado Anschutz Medical Campus
 *      Email: anna.maw@cuanschutz.edu
 * 
 * CODE REPOSITORY
 * ---------------
 *  GitHub: https://github.com/CUA-ACCORDS/ACCORDS-LHS-Core/tree/main/papers/ai-ambient-scribe-burnout-prism
 * 
 *******************************************************************************/

------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------

-- Evaluation period start date and end date
DECLARE @START_DATE DATE = '2025-01-13';
DECLARE @END_DATE DATE = '2025-08-01';

DECLARE @PARTICIPANTS TABLE (
    USER_ID NVARCHAR(50),
    LICENSE NVARCHAR(50),
    EMAIL NVARCHAR(50),
    ACTIVATED DATE,
    REMOVED DATE);

INSERT INTO @PARTICIPANTS (USER_ID, LICENSE, EMAIL, ACTIVATED, REMOVED)
VALUES 
    -- list of providers obfuscated from public GitHub release
    ; 

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- Pilot providers demographic and clinic informration
IF OBJECT_ID('tempdb.dbo.#providers') IS NOT NULL DROP TABLE #providers;

select p.USER_ID
, cs.PROV_ID
, cs2.NPI
, cs.PROV_NAME
, p.EMAIL
, p.LICENSE
, CASE WHEN p.ACTIVATED = '' THEN NULL ELSE p.ACTIVATED END [LICENSE_ACTIVATED] -- license activation date
, CASE WHEN p.REMOVED = '' THEN NULL ELSE p.REMOVED END [LICENSE_REMOVED] -- license removed date
, cs.PROV_TYPE
, cs.CLINICIAN_TITLE
, cs.SEX
, CONVERT(DATE, cs.BIRTH_DATE) [DOB]
, DATEDIFF(yy, cs.BIRTH_DATE, @START_DATE) - CASE WHEN DATEADD(yy, DATEDIFF(yy, cs.BIRTH_DATE, @START_DATE), cs.BIRTH_DATE) > @START_DATE THEN 1 ELSE 0 END [AGE_PILOT_COMMENCE]
, spec.NAME [PROVIDER_SPECIALTY]
, dep.DEPARTMENT_NAME
, dep.EXTERNAL_NAME [CLINIC_NAME]
, s.CLINIC_TYPE
INTO #providers
FROM @PARTICIPANTS p
    LEFT JOIN CLARITY_EMP ce on p.USER_ID = ce.USER_ID
        LEFT JOIN CLARITY_SER_SPEC css on ce.PROV_ID = css.PROV_ID and css.LINE = 1
            LEFT JOIN ZC_SPECIALTY spec on css.SPECIALTY_C = spec.SPECIALTY_C
        LEFT JOIN CLARITY_SER_DEPT csd on ce.PROV_ID = csd.PROV_ID and csd.LINE = 1
            LEFT JOIN CLARITY_DEP dep on csd.DEPARTMENT_ID = dep.DEPARTMENT_ID
                LEFT JOIN @SPECIALTIES s on dep.SPECIALTY = s.CLINIC_SPECIALTY
        LEFT JOIN CLARITY_SER cs on ce.PROV_ID = cs.PROV_ID
            LEFT JOIN CLARITY_SER_2 cs2 on cs.PROV_ID = cs2.PROV_ID
;

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- Provider working at multiple site check
IF OBJECT_ID('tempdb.dbo.#multiple_sites') IS NOT NULL DROP TABLE #multiple_sites;

SELECT p.USER_ID
, p.PROV_ID
, CASE WHEN COUNT(csd.LINE) > 1 THEN 1 ELSE 0 END [MULTIPLE_SITES]
INTO #multiple_sites
FROM #providers p 
    left join CLARITY_SER_DEPT csd on csd.PROV_ID = p.PROV_ID and csd.INACT_CAD_DEPT_YN = 'N'
GROUP BY p.USER_ID, p.PROV_ID
;
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- Information on all eligible encounters in the pilot, excluding PII 
IF OBJECT_ID('tempdb.dbo.#encounters') IS NOT NULL DROP TABLE #encounters;

SELECT DISTINCT p.PROV_ID
, p.PROV_NAME
, p.CLINIC_TYPE
, p.LICENSE
, pe.PAT_ENC_CSN_ID
, appt.NAME [ENCOUNTER_STATUS]
, pet.NAME [ENCOUNTER_TYPE]
, cp.EXTERNAL_NAME [VISIT_TYPE]
, CAST(pe.CONTACT_DATE AS DATE) [ENCOUNTER_DATE]
, format(DATEADD(DAY, 1 - DATEPART(WEEKDAY, pe.CONTACT_DATE), pe.CONTACT_DATE),'yyyy-MM-dd') [WEEK_OF]
, pe.DEPARTMENT_ID
, cd.DEPARTMENT_NAME
, nas.NOTE_ID
, hk.SEC_CLS_NAME [HAIKU_SEC_CLASS]
, peas.AMBIENT_SESSION_IDENT [ABRIDGE_SESSION_ID]
, dxr.DOCUMENT_ID [ABRIDGE_SESSION_DXR]
, CONVERT(DATE, pt1.BIRTH_DATE) [DOB]
, DATEDIFF(yy, pt1.BIRTH_DATE, pe.CONTACT_DATE) - CASE WHEN DATEADD(YY, DATEDIFF(yy, pt1.BIRTH_DATE, pe.CONTACT_DATE), pt1.BIRTH_DATE) > pe.HOSP_ADMSN_TIME THEN 1 ELSE 0 END [AGE_AT_ENCOUNTER]
, sex.NAME [PT_SEX]
, gi.NAME [PT_GENDER_IDENTITY]
, race2.NAME [PT_RACE]
, ethnic.NAME [PT_ETHNICITY]
, lang.NAME [PT_LANGUAGE]
, ms.NAME [PT_MARITAL_STATUS]
, payor.NAME [PT_INSURANCE_TYPE]
, pt1.ZIP [PT_ZIP]
, DATEDIFF(minute, vsa.ROOMED_DTTM, vsa.NURSE_LEAVE_DTTM) [ROOMING_TIME_MINS]
, CASE WHEN CAST(CONTACT_DATE AS DATE) = CAST(ENC_CLOSE_DATE AS DATE) THEN 1 ELSE 0 END [SAME_DAY_CLOSED]
, CASE WHEN peas.AMBIENT_SESSION_IDENT IS NOT NULL THEN 1 ELSE 0 END [ABRIDGE_INITIALIZED] -- recording session created
, CASE WHEN drns.DOCUMENT_ID IS NOT NULL THEN 1 ELSE 0 END [ABRIDGE_DOCUMENTED] -- abridge data returned
, CASE WHEN (p.LICENSE = 'License' AND CAST(pe.CONTACT_DATE AS DATE) >= p.LICENSE_ACTIVATED) OR p.LICENSE = 'Control' THEN 1 ELSE 0 END [ELIGIBLE_ENCOUNTER] -- eligible encounter check based on the day a provider's license was activated
INTO #encounters 
FROM #providers p 
    LEFT JOIN clarity.dbo.CLARITY_EMP_2 emp2 with (nolock) on p.USER_ID = emp2.USER_ID
        LEFT JOIN clarity.dbo.CLARITY_ECL hk with (nolock) on emp2.HKU_SEC_CLASS_ID = hk.ECL_ID
    LEFT JOIN clarity.dbo.PAT_ENC pe with (nolock) on p.PROV_ID = pe.VISIT_PROV_ID
        LEFT JOIN clarity.dbo.V_SCHED_APPT vsa with (nolock) on pe.PAT_ENC_CSN_ID = vsa.PAT_ENC_CSN_ID
        LEFT JOIN clarity.dbo.PAT_ENC_AMBIENT_SESSIONS peas with (nolock) on  peas.PAT_ENC_CSN_ID = pe.PAT_ENC_CSN_ID
            LEFT JOIN clarity.dbo.NOTE_AMBIENT_SECTIONS nas with (nolock) on peas.AMBIENT_SESSION_IDENT = nas.AMBIENT_SESSION_IDENT
                LEFT JOIN clarity.dbo.NOTE_SMARTSECTION_IDS nsi with (nolock) on nas.NOTE_ID = nsi.NOTE_ID AND nsi.SMARTSECTION_ID = 12300
        LEFT JOIN clarity.dbo.DOCS_RCVD_DETAILS dxr with (nolock) on dxr.DOCUMENT_EXT = peas.AMBIENT_SESSION_IDENT
            LEFT JOIN clarity.dbo.DOCS_RCVD_NOTE_SECTIONS drns with (nolock) on dxr.DOCUMENT_ID = drns.DOCUMENT_ID
        LEFT JOIN clarity.dbo.CLARITY_PRC cp with (nolock) on cp.PRC_ID = pe.APPT_PRC_ID
        LEFT JOIN clarity.dbo.ZC_DISP_ENC_TYPE pet with (nolock) on pe.ENC_TYPE_C = pet.DISP_ENC_TYPE_C
        LEFT JOIN clarity.dbo.ZC_APPT_STATUS appt with (nolock) on pe.APPT_STATUS_C = appt.APPT_STATUS_C
        LEFT JOIN clarity.dbo.CLARITY_DEP cd with (nolock) on cd.DEPARTMENT_ID = pe.DEPARTMENT_ID
        LEFT JOIN clarity.dbo.PATIENT pt1 with (nolock) on pt1.PAT_ID = pe.PAT_ID            
            LEFT JOIN clarity.dbo.PATIENT_4 pt4 with (nolock) on pt1.PAT_ID = pt4.PAT_ID
                LEFT JOIN clarity.dbo.ZC_GENDER_IDENTITY gi with (nolock) on pt4.GENDER_IDENTITY_C = gi.GENDER_IDENTITY_C
            LEFT JOIN clarity.dbo.ZC_SEX sex with (nolock) on pt1.SEX_C = sex.RCPT_MEM_SEX_C
            LEFT JOIN clarity.dbo.PATIENT_RACE race1 with (nolock) on pt1.PAT_ID = race1.PAT_ID and race1.LINE = 1                
                LEFT JOIN clarity.dbo.ZC_PATIENT_RACE race2 with (nolock) on race1.PATIENT_RACE_C = race2.PATIENT_RACE_C
            LEFT JOIN clarity.dbo.ZC_ETHNIC_GROUP ethnic with (nolock) on pt1.ETHNIC_GROUP_C = ethnic.ETHNIC_GROUP_C
            LEFT JOIN clarity.dbo.ZC_LANGUAGE lang with (nolock) on pt1.LANGUAGE_C = lang.LANGUAGE_C
            LEFT JOIN clarity.dbo.ZC_MARITAL_STATUS ms with (nolock) on pt1.MARITAL_STATUS_C = ms.MARITAL_STATUS_C
            LEFT JOIN clarity.dbo.ACCOUNT acc with (nolock) on acc.ACCOUNT_ID = pe.ACCOUNT_ID
                LEFT JOIN clarity.dbo.ZC_FIN_CLASS payor with (nolock) on acc.FIN_CLASS_C = payor.FIN_CLASS_C    
WHERE pe.CONTACT_DATE >= @START_DATE 
    AND pe.CONTACT_DATE < @END_DATE
    AND pe.APPT_STATUS_C = 2 --  Completed
    AND pe.ENC_TYPE_C IN (
        '2109084000', '2109080009', '2109080005', '2109012020', '1307100007', '1307100005', '1307100003', '1307100002', '10015', '10008', '10003', '10000', '2511', '2509', '2502', '2501', '2500', '2102', '2100', '1214', '1201', '1200', '1004', '1000', '213', '120', '101', '91', '49', '31', '2'
    ) -- list of associated eligible encounter types included in supporting documentation
    AND pe.APPT_PRC_ID IN (
        '415031', '103090', '804536', '103042', '100081', '413207', '704531', '103041', '504527', '5093', '804527', '100027', '504618', '413412', '103036', '413171', '100079', '415007', '415041', '415019', '415082', '415008', '415074', '415078', '415075', '415026', '415023', '415081', '415029', '415090', '415127', '415091', '415000', '415073', '415076', '415038', '415085', '415024', '415110', '415034', '415070', '415124', '415125', '415080', '415037', '415084', '415077', '415128', '415072', '415079', '415036', '415071', '415083', '415039', '415009', '415022', '27257', '415017', '415014', '100059', '413538', '103039', '505315', '2087', '100108', '413721', '413720', '413395', '413396', '415101', '100225', '100018', '505310', '804504', '804546', '4101', '100152', '24', '504504', '4016', '413297', '13108', '2081', '704503', '413377', '103011', '100008', '425012', '12155', '4542', '504521', '413233', '413103', '103005', '100014', '413295', '413128', '805255', '804514', '413148', '413385', '413381', '103006', '413723', '413113', '103227', '704504', '100022', '103016', '413251', '504514', '413379', '413291', '413457', '505308', '100003', '804501', '504502', '413101', '504501', '413147', '2095', '413149', '415111', '704502', '103020', '100004', '413121', '804502', '25121', '413102', '103004', '413150', '100002', '5004', '414837', '12103', '100009', '504509', '704509', '804509', '103202', '103206', '5128', '103092', '414851', '4529', '19725', '19723', '4032', '4038', '103127', '415035', '425004', '425003', '5500', '804505', '704505', '425008', '413292', '413296', '2080', '100005', '504505', '4509', '413378', '103007', '33107', '413106', '504510', '804510', '504626', '100010', '103012', '704510', '504627', '413224', '12113', '100006', '704506', '4510', '103008', '413293', '504506', '804506', '413107', '415005', '4034', '413386', '19743', '19741', '13124', '425025', '103096', '100248', '100203', '804597', '704538', '103201', '425032', '100140', '5097', '103084', '6083', '415027', '415021', '415020', '415025', '413514', '103003', '704534', '5127', '7059', '504503', '414835', '11043', '425017', '504513', '505307', '413247', '413376', '103002', '425028', '413248', '425021', '103010', '13123', '413146', '100001', '12154', '413722', '425019', '4100', '103015', '100053', '100013', '13107', '413163', '413108', '100207', '425011', '413483', '804513', '413482', '504508', '413294', '505337', '413129', '804503', '413290', '413380', '5000', '413143', '100021', '413391', '425020', '11042', '413245', '413707', '413390', '4015', '504520', '704508', '413242', '413241', '413250', '413232', '704501', '704513', '804508', '413145', '4030', '103152', '4507', '12107', '425013', '805266', '425018', '413100', '425000', '2089', '102000', '7052', '103001', '504500', '804500', '2079', '704500', '103023', '415200', '413700', '100000', '12102', '5001', '103205', '6014', '103081', '100223', '4002', '103156', '100222', '4037', '425033', '505295', '413455', '505316', '50298', '413389', '415003', '415016', '415004', '41330', '103197', '103198', '4103', '4102', '12100', '505340', '413222', '413220', '505304', '100054', '505317', '7021', '103088', '103038', '425005', '4035', '413388', '100167', '504624', '103190', '103078', '14104', '25112', '25106', '103158', '425024', '425001', '413459', '13159', '413154', '4031', '505305', '413411', '7020', '100229', '504528', '25161', '25134', '704528', '413123', '804528', '25143', '25160', '7019', '413427', '100175', '103028', '100028', '413419', '504603', '804545', '414845', '100224', '100034', '504507', '100234', '100181', '103033', '100007', '804507', '504619', '100151', '100049', '103009', '704507', '103188', '100033', '5074', '425002', '100233', '415032'
    ) -- list of associated eligible visit types included in supporting documentation
;

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

-- Encounters aggregated to provider level for final output
IF OBJECT_ID('tempdb.dbo.#enc_rollup') IS NOT NULL DROP TABLE #enc_rollup;

SELECT PROV_ID
, COUNT(DISTINCT PAT_ENC_CSN_ID) [ENCOUNTERS]
, SUM(ELIGIBLE_ENCOUNTER) [ELIGIBLE_ENCOUNTERS]
, SUM(ABRIDGE_INITIALIZED) [ABRIDGE_INITIALIZED] 
, SUM(ABRIDGE_DOCUMENTED) [ABRIDGE_DOCUMENTED]
INTO #enc_rollup
FROM #encounters
GROUP BY PROV_ID
;

----------------------------------------------------------------------------------------------------------------
-- Final queries
----------------------------------------------------------------------------------------------------------------

-- Final provider query - combines demographics, abridge useage, encounter rollup, and multiple sites marker
select p.USER_ID
, p.PROV_ID
, p.NPI
, p.PROV_NAME
, p.EMAIL
, p.LICENSE
, p.LICENSE_ACTIVATED
, p.LICENSE_REMOVED
, p.PROV_TYPE
, p.CLINICIAN_TITLE
, p.SEX
, p.DOB
, p.AGE_PILOT_COMMENCE
, p.PROVIDER_SPECIALTY
, p.DEPARTMENT_NAME
, p.CLINIC_NAME
, p.CLINIC_TYPE
, case when er.ABRIDGE_INITIALIZED is null then 0 else er.ABRIDGE_INITIALIZED end [ABRIDGE_INITIALIZED]
, case when er.ABRIDGE_DOCUMENTED is null then 0 else er.ABRIDGE_DOCUMENTED end [ABRIDGE_DOCUMENTED]
, case when er.ELIGIBLE_ENCOUNTERS is null then 0 else er.ELIGIBLE_ENCOUNTERS end [ELIGIBLE_ENCOUNTERS] -- eligible encounters count based on date of activation
, case when er.ENCOUNTERS is null then 0 else er.ENCOUNTERS end [ENCOUNTERS] -- total eligible enounters that meet the eligible encounter and visit types requirements
, ms.MULTIPLE_SITES
from #providers p
    left join #enc_rollup er on p.PROV_ID = er.PROV_ID
    left join #multiple_sites ms on p.PROV_ID = ms.PROV_ID
order by p.LICENSE desc, p.PROV_NAME
;

----------------------------------------------------------------------------------------------------------------

-- Encounters
select PAT_ENC_CSN_ID 
, PROV_ID
, PROV_NAME
, CLINIC_TYPE
, LICENSE
, ENCOUNTER_STATUS
, ENCOUNTER_TYPE
, VISIT_TYPE
, ENCOUNTER_DATE
, WEEK_OF
, DEPARTMENT_ID
, DEPARTMENT_NAME
, NOTE_ID
, HAIKU_SEC_CLASS
, ABRIDGE_SESSION_ID
, ABRIDGE_SESSION_DXR
, DOB
, AGE_AT_ENCOUNTER
, PT_SEX
, PT_GENDER_IDENTITY
, PT_RACE
, PT_ETHNICITY
, PT_LANGUAGE
, PT_MARITAL_STATUS
, PT_INSURANCE_TYPE
, PT_ZIP
, ROOMING_TIME_MINS
, SAME_DAY_CLOSED
, ABRIDGE_INITIALIZED
, ABRIDGE_DOCUMENTED
, ELIGIBLE_ENCOUNTER
from #encounters
order by PROV_NAME, ENCOUNTER_DATE
;

---
