import pandas as pd

# Load the CSV data
goog_rev = pd.read_csv("GOOGLE REVIEW1.csv")

# Select the first 49 rows
data = goog_rev[0:49]

# Drop unnecessary columns
data = data.drop(columns=["Date"])

# Convert reviews to a list
reviews = [review for review in data["GOOGLE REVIEWS"]]

# Function to label reviews as positive or negative
def label_review(rating):
    if rating == 5 or rating == 4:
        return 'positive'
    else:
        return 'negative'

# Apply the function to the 'Rating' column
data['Sentiment'] = data['Rating'].apply(label_review)

# Define keywords for food and owner
food_keywords = ["burger", "boba", "food", "meal", "breakfast", "delicious", "tasty", "options"]
owner_keywords = ["Marco", "owner", "uncle", "friendly", "welcoming", "Macro", "boss"]

# Function to classify reviews
def classify_review(review):
    review_lower = review.lower()  # make case-insensitive
    is_food = any(word in review_lower for word in food_keywords)
    is_owner = any(word in review_lower for word in owner_keywords)

    if is_food and is_owner:
        return "both"
    elif is_food:
        return "food"
    elif is_owner:
        return "owner"
    else:
        return "neither"

# Apply the classification to all reviews
classifications = [classify_review(review) for review in reviews]

# Add the classifications to the DataFrame
data["Label"] = classifications

# Save the classified reviews to a new CSV file
data.to_csv('classified_ggreviews.csv', index=False)
print("Classification completed. Results saved to 'classified_ggreviews.csv'")