# **SQL Database Setup Guide**

## **What This Is**
A complete video game store database with 21 tables of sample data. This database includes users, games, reviews, orders, and Web3 features for practicing SQL queries.

## **Prerequisites**

**What you need before starting:**
- MySQL installed (version 8.0 or higher)
- Command Prompt or Terminal access
- VS Code (recommended) or any text editor

**How to check if MySQL is installed:**
Open Command Prompt and type:
```
mysql --version
```
If you see version information, you're ready. If you see "command not found", download MySQL from mysql.com and install it.

## **Setting Up and Running**

### **Step 1: Download and Organize Files**
1. Create a folder called `sql-practice` on your Desktop
2. Inside this folder, place your SQL files:
   - `gamehub.sql` (main database file)
   - `view_schema.sql` (schema exploration file)
   - Any other practice SQL files

### **Step 2: Create the Database**
Open Command Prompt and navigate to your folder:
```
cd Desktop/sql-practice
```

Create the gamehub database:
```
mysql -u root -p < gamehub.sql
```
When prompted for password, enter your MySQL password (or press Enter if no password).

### **Step 3: Verify Installation**
Check if everything worked:
```
mysql -u root -p -e "USE gamehub; SHOW TABLES;"
```

## **Project Structure**
```
sql-practice/
├── gamehub.sql               # Main database creation file
├── view_schema.sql           # Schema exploration queries
├── sessions/                  # Your practice session files
│   └── my_practice.sql
└── exercises/                 # Your custom query files
    └── custom_queries.sql
```

## **How to Use This Database**

### **Method 1: Using Session Files**
This is the workflow we successfully used:

1. **Open `view_schema.sql`** in your editor
2. **Copy** any query section you want to practice
3. **Create a new file** in `sessions/` folder
4. **Paste** the query into your session file
5. **Modify and experiment** with the query
6. **Run it** using one of these methods:

**In Command Prompt:**
```
mysql -u root -p gamehub < sessions/your_file.sql
```

**In VS Code:**
- Install MySQL extension
- Connect to `127.0.0.1` with database `gamehub`
- Open your session file
- Right-click and select "Run MySQL Query"

### **Method 2: Creating Custom Queries**
For when you're ready to write your own SQL:

1. **Create a new file** in `exercises/` folder
2. **Start with simple queries**, then build complexity
3. **Reference the schema** when you need column names
4. **Test frequently** and fix errors as you go

## **Database Contents**
Your database now has:
- 21 tables with real-world relationships
- Sample users with gaming profiles
- Popular games with prices and ratings
- Game reviews and ratings
- User library and playtime data
- Order history and payments
- Game genres and platforms

## **Common Database Commands**

**Start MySQL:**
```
mysql -u root -p
```

**Select database:**
```
USE gamehub;
```

**Run SQL file:**
```
mysql -u root -p gamehub < yourfile.sql
```

**Single query from command line:**
```
mysql -u root -p gamehub -e "SELECT * FROM games;"
```

## **Troubleshooting**

**Database already exists error:**
```
mysql -u root -p -e "DROP DATABASE gamehub;"
mysql -u root -p < gamehub.sql
```

**Can't connect to MySQL:**
1. Check if MySQL service is running
2. Try `127.0.0.1` instead of `localhost`
3. Verify username and password

**VS Code not showing data:**
1. Use `127.0.0.1` as host
2. Database name is `gamehub`
3. Refresh the connection (right-click → Refresh)

## **Success Tips**
1. **Practice regularly** - Even 15 minutes helps
2. **Start with session files** - Copy from `view_schema.sql`
3. **Experiment boldly** - Try changing queries to see what happens
4. **Save your work** - Keep session files organized
5. **Use both methods** - Command line for quick tests, VS Code for longer sessions

## **Getting Help**
If stuck, check:
1. The `view_schema.sql` file for example queries
2. Command Prompt error messages
3. MySQL documentation at dev.mysql.com

---

**Remember**: This database was tested and works. Follow the steps exactly, and you'll have a working SQL environment ready for practice.