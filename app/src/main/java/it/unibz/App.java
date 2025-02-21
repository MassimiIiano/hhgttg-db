package it.unibz;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;


public class App {
    public static void main(String[] args) {
        String url = "jdbc:postgresql://" + System.getenv("POSTGRES_HOSTNAME") + "/" + System.getenv("POSTGRES_DB");
        String user = System.getenv("POSTGRES_USER");
        String password = System.getenv("POSTGRES_PASSWORD");

        try (Connection conn = DriverManager.getConnection(url, user, password)) {
            System.out.println("Connected to the PostgreSQL database successfully!");

            Scanner scanner = new Scanner(System.in);
            // ask user for imput untill he quits
            while (true) {
                System.out.print("Enter a command: \n1. Insert a trip\n2. Get entries\n3. Add a general entry\n4. Best location in sector\nType 'quit' to exit\n>>");
                // read user input
                String input = scanner.nextLine();
                if (input.equalsIgnoreCase("quit")) {
                    break;
                }
                switch (input) {
                    case "1":
                        // ask for necessary information
                        System.out.print("Enter your pid: ");
                        int pid = scanner.nextInt();
                        scanner.nextLine();
                        System.out.print("Enter the location: ");
                        String location = scanner.nextLine();
                        System.out.print("Enter the start date (YYYY-MM-DD): ");
                        String start = scanner.nextLine();
                        System.out.print("Enter the end date (YYYY-MM-DD): ");
                        String end = scanner.nextLine();
                        System.out.print("Enter the score (1 to 100): ");
                        int score = scanner.nextInt();
                        // insert the trip
                        insertTrip(conn, pid, location, start, end, score);
                        break;
                
                    case "4":
                        System.out.print("Enter sector name: ");
                        String sector = scanner.nextLine();
                        bestLocationInSector(conn, sector);
                        break;
                    default:
                        System.out.println( "'"+  input + "'" + " is an invalid command, try again");
                        break;
                }

                scanner.close();

            }

        } catch (SQLException e) {
            System.err.println("Connection failed: " + e.getMessage());
        } 
    }



    static void insertTrip(Connection c, int pid, String location, String start, String end, int score) {
        String query = "INSERT INTO Trip (startDate, endDate, person, location, score) VALUES (?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = c.prepareStatement(query)) {
            // Set the parameters for the prepared statement
            pstmt.setDate(1, java.sql.Date.valueOf(start));
            pstmt.setDate(2, java.sql.Date.valueOf(end));  
            pstmt.setInt(3, pid);
            pstmt.setString(4, location);
            pstmt.setInt(5, score);
    
            // Execute the insert statement
            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("Trip inserted successfully!");
            } else {
                System.out.println("Failed to insert trip.");
            }
        } catch (SQLException e) {
            System.err.println("Failed to insert trip: " + e.getMessage());
        }
    }

    static void getEntries(Connection c, String keyword) {}

    static void addGeneralEntry(Connection c, String author, String title, String text) {}

    static void bestLocationInSector(Connection c, String sector) {
        String query = "SELECT name, rating FROM Location " +
                       "WHERE sector = ? AND rating = (" +
                       "  SELECT MAX(rating) FROM Location WHERE sector = ?" +
                       ") ORDER BY rating DESC";
        
        try (PreparedStatement pstmt = c.prepareStatement(query)) {
            pstmt.setString(1, sector);
            pstmt.setString(2, sector);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                System.out.println("\n--- Best locations in sector '" + sector + "' ---");
                
                if (!rs.isBeforeFirst()) {
                    System.out.println("No locations found in this sector");
                    return;
                }
                
                while (rs.next()) {
                    String name = rs.getString("name");
                    int rating = rs.getInt("rating");
                    System.out.printf("- %s (Rating: %d)%n", name, rating);
                }
            }
        } catch (SQLException e) {
            System.err.println("Error fetching locations: " + e.getMessage());
        }
    }
}
