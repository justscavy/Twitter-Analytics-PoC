import pandas as pd
from ntscraper import Nitter
import mysql.connector
from datetime import datetime

scraper = Nitter()
"""
##get tweets with information from spec. user
def get_tweets(name, modes, no) -> list:
    #init scraper with given param.
    tweets: str = scraper.get_tweets(name,mode = modes, number = no)
    tweets_data: list = []
    #start for loop to iterate through tweets
    for tweet in tweets['tweets']:
        data = [tweet['text'], tweet['date'], tweet['stats']['likes'], tweet['stats']['comments']] 
        tweets_data.append(data)
    #convert list with pandas to DF
    data = pd.DataFrame(tweets_data, columns =['text', 'date', 'No_of_Likes', 'No_of_tweets'])
    #save as csv file
    data.to_csv('tweetstest.csv')
    #print(data)
    return data
"""
"""get information about user"""
def get_profile_info(name, max_retries=5, instance=None) -> dict:
    user = scraper.get_profile_info(name)
    user_data = {
        'username': user['username'],
        'name': user['name'],
        'user_id': user['id'],
        'location': user['location'],
        'joined': datetime.strptime(user['joined'], '%I:%M %p - %d %b %Y').strftime('%Y-%m-%d %H:%M:%S'),
        'No_of_tweets': user['stats']['tweets'],
        'following': user['stats']['following'],
        'followers': user['stats']['followers'],
        'No_of_Likes': user['stats']['likes']
    }
    #print(user_data)
    return user_data


class DBManager:
    """Connect to DB."""
    def __init__(
        self,
        host: str = "localhost",    #change to ur local db
        user: str = "root",
        password: str = "ubuntu123",
        database: str = "SMA_final"
    ) -> None:
        self.connection = mysql.connector.connect(
            host=host,
            user=user,
            password=password,
            database=database
        )
    

    def insert_user_data(self, username: str, name: str, location: str, joined: str, 
                     no_of_tweets: int, following: int, followers: int, no_of_likes: int):
        try:
            cursor = self.connection.cursor()
            cursor.execute("""
                INSERT INTO User_demo 
                (username, name, location, joined, No_of_tweets, following, followers, No_of_likes) 
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            """, (username, name, location, joined, no_of_tweets, following, followers, no_of_likes))
            
            self.connection.commit()
            
            if cursor.rowcount > 0:
                return True
            else:
                return False
        except mysql.connector.Error as e:
            print(f"SQL query failed. Details: '{e}'")
            return False



user_data = get_profile_info("nypost")
try:
    no_of_likes = user_data['No_of_likes']
except KeyError:
    no_of_likes = None

db_manager = DBManager()
insert_result = db_manager.insert_user_data(
    user_data['username'],
    user_data['name'],
    user_data['location'],
    user_data['joined'],
    user_data['No_of_tweets'],
    user_data['following'],
    user_data['followers'],
    no_of_likes
)



