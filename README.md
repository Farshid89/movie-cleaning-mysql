# 🎬 Movie Dataset Cleaning (MySQL 8.0)

This project demonstrates a **production-minded SQL data cleaning pipeline** applied to a messy movie dataset.  
It covers staging, schema normalization, deduplication, text cleanup (CR/LF), feature extraction (director vs. stars), numeric sanitation and type casting, and quality checks.

---

## 🚀 Why this project is portfolio-worthy
- Works on a **staging table** → raw data stays untouched  
- Cleans both **Windows/Unix newlines**  
- Splits mixed columns → `director` & `stars`  
- Cleans numeric text (`votes`, `runtime`, `rating`) into proper types  
- Includes **validation queries** and constraints awareness  

---

## 🛠️ Tech
- **MySQL 8.0+** (uses `REGEXP_REPLACE`, CTEs, window functions)
- Can be run in MySQL Workbench, CLI, or a Docker container

---

## 📂 Files
- `sql/01_cleaning.sql` → main cleaning script  
- `sql/02_quality_checks.sql` → validation & exploration queries  
- `data/movies_sample.csv` → small sample of raw input data  
- `LICENSE` → MIT License  

---
## 📊 Before vs After

**Raw data (before cleaning):**

![Before cleaning](images/before.png)

**Cleaned data (after SQL pipeline):**

![After cleaning](images/after.png)
## ▶️ How to Run
1. Load the sample (or your own) data into a table called `movies`.  
2. Run the cleaning script:

   ```bash
   mysql -u youruser -p yourdb < sql/01_cleaning.sql
