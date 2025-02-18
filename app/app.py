import psycopg2
from psycopg2 import sql
import sys

conn = None
try:
    # Establish database connection
    conn = psycopg2.connect(
        dbname="hhgttg",
        user="postgres",
        password="postgres",
        host="db",
        port="5432"
    )
except psycopg2.DatabaseError as e:
    print(f"Error: {e}")
    if conn:
        conn.close()
    sys.exit(1)


def add_entry(title, text, author_id, category=None, category_id=None):
    """
    Adds a new entry to the database in the specified category.
    
    Parameters:
        title (str): Entry title
        text (str): Entry content
        author_id (int): Author ID (must exist in Author table)
        category (str, optional): Entry category ('location', 'person', or 'species')
        category_id (str/int, optional): ID for the category (location name, vip ID, or species ID)
    
    Returns:
        int: The ID of the newly created entry.
    """
    
    with conn.cursor() as cur:
        try:
            # Insert into Entry table and return the new entry ID
            cur.execute(
                "INSERT INTO Entry (title, text, author) VALUES (%s, %s, %s) RETURNING ied",
                (title, text, author_id)
            )
            new_entry_id = cur.fetchone()[0]  # Fetch the generated ID
            
            conn.commit()
            print(f"Entry added with ID: {new_entry_id}")

            # Insert into appropriate category table if applicable
            if category and category_id:
                if category == 'location':
                    cur.execute("INSERT INTO LocationEntry (entry, location) VALUES (%s, %s)", 
                                (new_entry_id, category_id))
                elif category == 'person':
                    cur.execute("INSERT INTO PersonEntry (entry, vip) VALUES (%s, %s)", 
                                (new_entry_id, category_id))
                elif category == 'species':
                    cur.execute("INSERT INTO SpeciesEntry (entry, species) VALUES (%s, %s)", 
                                (new_entry_id, category_id))
                else:
                    print("Invalid category.")
                    conn.rollback()
                    raise Exception("Invalid category.")

                conn.commit()
                print(f"Entry linked to {category}: {category_id}")

            return new_entry_id  # Return the created entry ID

        except psycopg2.DatabaseError as e:
            print(f"Error: {e}")
            conn.rollback()
            return None  # Return None in case of an error

def insert_trip(startDate: str, endDate: str, person: int, location: str, score: int):
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO Trip (startDate, endDate, person, location, score) VALUES (%s, %s, %s, %s, %s)",
                (startDate, endDate, person, location, score)
            )
            conn.commit()
            
    except psycopg2.DatabaseError or Exception as e:
        print(f"Error: {e}")
        conn.rollback()
        return None

def best_location_in_sector(sector: str):
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT location, AVG(score) FROM Trip WHERE location IN (SELECT name FROM Location WHERE sector = %s) GROUP BY location ORDER BY AVG(score) DESC LIMIT 1",
                (sector,)
            )
            best_location = cur.fetchone()
            return best_location
    except psycopg2.DatabaseError or Exception as e:
        print(f"Error: {e}")
        return None

def get_most_used_spacecreaft():
    try:
        with conn.cursor() as cur:
            cur.execute(
                "SELECT spacecraft, COUNT(*) AS usage_count FROM uses GROUP BY spacecraft ORDER BY usage_count DESC LIMIT 1;"
            )
            most_used_spacecraft = cur.fetchone()
            return most_used_spacecraft
    except psycopg2.DatabaseError or Exception as e:
        print(f"Error: {e}")
        return None

def get_entry(title: str, category: str):
    try:
        with conn.cursor() as cur:
            cur.execute(
                '''
            SELECT 
                e.ied, 
                e.title, 
                e.text, 
                e.author
            FROM 
                Entry e
            LEFT JOIN LocationEntry le ON e.ied = le.entry
            LEFT JOIN PersonEntry pe ON e.ied = pe.entry
            LEFT JOIN SpeciesEntry se ON e.ied = se.entry
            LEFT JOIN Location l ON le.location = l.name
            LEFT JOIN Person p ON pe.vip = p.pid
            LEFT JOIN Species s ON se.species = s.sid
            WHERE 
                e.title = %s
                AND (
                    (%s = 'location' AND le.location IS NOT NULL) OR
                    (%s = 'person' AND pe.vip IS NOT NULL) OR
                    (%s = 'species' AND se.species IS NOT NULL) OR
                    (%s IS NULL AND le.location IS NULL AND pe.vip IS NULL AND se.species IS NULL)
                    OR
                    (%s = l.name) OR  -- Match location name
                    (%s = p.name) OR  -- Match person name
                    (%s = s.name)     -- Match species name
                );
        '''     ,
                (title, category, category, category, category, title, title, title)
            )
            entry = cur.fetchone()
            return entry
    except psycopg2.DatabaseError or Exception as e:
        print(f"Error: {e}")
        return None

if __name__ == '__main__':
    # Add a new entry
    new_id = add_entry(
        title="The Hitchhiker's Guide to the Galaxy",
        text="The Hitchhiker's Guide to the Galaxy is a comedy science fiction series created by Douglas Adams.",
        author_id=2
    )
    print(f"New Entry ID: {new_id}")

    # add a new trip
    new_trip_id = insert_trip("2021-01-01", "2021-01-10", 1, "Vogon Homeworld", 100)

    # ger best location in sector
    best_location = best_location_in_sector('Sol Sector')
    print(best_location)

    # get the most used spacecraft by travelers
    most_used_spacecraft = get_most_used_spacecreaft()
    print(most_used_spacecraft)

    # find an entry about location in the guide
    entry = get_entry("Earth", "location")
    print(entry)

    conn.close()
