# ACCORDS Learning Health Systems (LHS) Core — EHR Extraction & Reproducible Research Code

This repository contains code artifacts developed by the **ACCORDS Learning Health Systems Core** to support transparent, reproducible health systems research and quality improvement using real-world data.

The ACCORDS LHS Core empowers health systems to evolve—turning everyday care into a source of learning and improvement. We help develop and implement integrated, continuous, systematic approaches for self-study to improve health outcomes by leveraging real-world data and advanced analytics to generate actionable knowledge. We engage stakeholders across disciplines, and implement and evaluate changes in practice.

## Mission and goal

The ACCORDS LHS Core bridges the gap between research and real-world practice by helping clinicians transform quality improvement and research projects into Learning Health Systems—organizations and networks that continuously self-study and adapt using data, analytics, and stakeholder input to drive meaningful change in health care.

Our goal is to ensure that science is not only rigorous, but also responsive to the needs of health care systems and the communities they serve.

---

## What this repository provides

This repository is primarily intended for **external academic users** who want to understand, reproduce, or adapt methods described in manuscripts supported by the ACCORDS LHS Core.

Typical contents include:

- **SQL Server queries** used to define cohorts, derive features/variables, and construct analysis datasets from Epic reporting data environments (e.g., Clarity/Caboodle or locally curated SQL Server data marts).
- Optional **Python scripts** used to parameterize and execute SQL in a consistent order and to generate standardized, analysis-ready outputs.
- **Code lists / value sets** (as CSV or similar formats) that define clinical concepts (e.g., ICD-10, CPT, LOINC, RxNorm), where permissible to share.
- **Documentation** describing cohort logic, variable definitions, and expected outputs.

> This repository is designed to make the *methods* for EHR data extraction transparent and reusable. It does **not** include patient-level data.

---

## Repository organization

This repository is organized to support reuse across multiple studies while keeping each manuscript/project self-contained:

- `papers/`  
  Paper- or project-specific logic. Each subfolder in `papers/` contains the cohort definition, code lists, SQL, and (if applicable) analysis scripts used for a particular manuscript or study, along with a paper-specific README.

A typical paper folder includes:
- `papers/<paper-id>/sql/` — ordered SQL scripts (cohort → features → outcomes → analysis dataset)
- `papers/<paper-id>/codelists/` — CSV code lists (ICD-10, CPT, LOINC, RxNorm, etc.)
- `papers/<paper-id>/analysis/` — analysis runner (optional; often Python)
- `papers/<paper-id>/README.md` — paper-specific run instructions and output definitions

---

## Intended use and prerequisites

### Intended users
This code is intended for researchers/analysts who have:
- authorized access to an Epic reporting database environment,
- knowledge of their local Epic data model and mappings, and
- approval to query and use EHR data under applicable IRB / compliance policies.

### Prerequisites
To run the SQL in your own environment, you will typically need:
- SQL Server query tooling (e.g., SSMS or Visual Studio Code)
- appropriate permissions to query required tables/views in your Epic reporting environment
- local site-specific mappings and configuration (see **Site adaptation** below)

---

## Data availability, privacy, and governance

- **No patient-level data** are included in this repository.
- Execution requires **authorized local access** to an Epic reporting database (or an equivalent local SQL Server data warehouse/mart).
- Users must comply with their institution’s privacy, security, and governance requirements when running these queries.
- Do not include PHI in GitHub Issues, discussions, or pull requests.

If this repository is associated with a specific manuscript, please refer to that manuscript’s data availability statement and the corresponding `papers/<paper-id>/README.md` for any additional constraints.

---

## Site adaptation (expected changes for external users)

Epic implementations and local data marts vary. External users should expect to adapt some components, such as:
- database names / schema names
- table/view names (Clarity vs Caboodle vs local marts)
- local identifiers (department IDs, location IDs, provider identifiers)
- code mappings and value sets (where local coding differs)
- date windows and inclusion/exclusion parameters (per protocol)

Paper- or project-specific folders should describe what is assumed vs what must be edited locally.

---

## How to cite

If you use or adapt this repository, please cite:
- the associated manuscript (when applicable), and
- the software release for this repository.

Citation metadata is provided in `CITATION.cff` (recommended for GitHub’s “Cite this repository” feature).

---

## License

See `LICENSE`.

---

## Maintainers / contact

Maintained by the **ACCORDS Learning Health Systems Core**.

- Website: https://medschool.cuanschutz.edu/accords/CoresResources/learning-health-systems-(lhs)
- Contact: [Katy E Trinkley, PharmD, PhD](mailto:katy.trinkley@cuanschutz.edu); [Tyler Anstett, DO](mailto:tyler.anstett@cuanschutz.edu)
- Institution: Adult & Child Center for Outcomes Research & Delivery Science (ACCORDS), University of Colorado Anschutz Medical Campus, Aurora, CO, USA
