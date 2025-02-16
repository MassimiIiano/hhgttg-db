import psycopg2
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

if __name__ == '__main__':
    # Add a new entry
    new_id = add_entry(
        title="The Hitchhiker's Guide to the Galaxy",
        text="The Hitchhiker's Guide to the Galaxy is a comedy science fiction series created by Douglas Adams.",
        author_id=2
    )
    print(f"New Entry ID: {new_id}")

    # add a new trip
    new_trip_id = insert_trip("2021-01-01", "2021-01-10", 1, "Vogon Homeworld", 1)

    conn.close()
