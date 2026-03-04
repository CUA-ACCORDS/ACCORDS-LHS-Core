# Implementation and evaluation of AI ambient scribes to reduced clinician burnout: a pragmatic mixed methods embedded randomized trial

This folder contains the **EHR extraction SQL** developed to support the manuscript:

**Implementation and evaluation of AI ambient scribes to reduced clinician burnout: a pragmatic mixed methods embedded randomized trial**

> Scope note: This project folder is intentionally limited to **SQL Server (T-SQL) scripts** used for EHR data pulls and supporting documentation. No patient-level data are included, and the code is only runnable by teams with appropriate local access to Epic Clarity/Caboodle reporting databases.

---

## Authors

Manuscript authors:  
Anna Maw, MD, MS; C.T. Lin, MD; Carter J Sevick, PhD; Karen Chacko, MD; Juliana G. Barnard, MA; Nico Punkar, MPA; Vanessa L Richardson, MS; Bryan Pfalzgraf; Brad Morse, PhD, MA; Mariarosa Gasbarro, MA; James Dillingham, PA-C; Liselotte N Dyrbye, MD, MHPE; Jennifer Simpson, MD; Eden English, MD; Katy E Trinkley, PharmD, PhD

Code author (EHR SQL):  
- Bryan Pfalzgraf

---

## What is included

- `sql/` — SQL Server (T-SQL) scripts used to extract EHR-derived data elements for this study.

### SQL files (current placeholders)
- `sql/01_AmbientScribe_ProvidersEncounters.sql` — encounter-level and provider-level data extraction and study-period logic

> As the project is finalized, this section will be updated to reflect the actual file names and what each script produces.

---

## What is not included

- Patient-level data, clinician-level identifiable data, or any direct database extracts
- Credentials, connection strings, server names, or any institution-specific secret material
- Python/R/SAS analysis code, notebooks, or manuscript generation scripts
- Epic-specific build documentation or vendor-proprietary content

---

## Requirements / assumptions

To run these scripts, you must have:
- Authorized access to a **SQL Server–backed Epic reporting environment** (or equivalent local data mart)
- Local knowledge of table/view mappings in your environment
- Institutional approvals required to query and use EHR data

These scripts are provided to support transparency and adaptation; external users should expect to modify:
- database/schema/table names
- local identifier mappings
- date parameters and study windows as needed to match your protocol

---

## Outputs

This repository does not include outputs. The SQL scripts are expected to generate one or more of the following (implementation-dependent):
- intermediate cohort tables (restricted)
- analysis dataset tables (restricted)
- aggregate summaries suitable for manuscript tables/figures

---

## Data availability

Because this work involves EHR data, patient-level data cannot be shared via this repository. Researchers wishing to reproduce the EHR portion of this study must have appropriate access to their own Epic reporting data and approvals under their local governance processes.

---

## License

See the repository-level [`LICENSE`](../../LICENSE).

---

## Contact

For questions about this EHR SQL code:
- [Bryan Pfalzgraf](mailto:bryan.pfalzgraf@cuanschutz.edu)

For programmatic/institutional context:
- ACCORDS Learning Health Systems Core (see top-level README)
