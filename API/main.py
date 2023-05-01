from fastapi import FastAPI
import tensorflow as tf
import numpy as np
import pandas as pd
from typing import List


app = FastAPI()

# Load the trained TensorFlow model
model = tf.keras.models.load_model('./model/model.h5')

# Load the dataset
df = pd.read_csv('./data/interactions_train_df.csv')
df = df[['user_id', 'content_id', 'game', 'view']]

# Content Data of Games
df_game = pd.read_csv('./data/articles_df.csv')
df_game.head(4)

# Creating a sparse pivot table with users in rows and items in columns
users_items_matrix_df = df.pivot(index='user_id',
                                 columns='content_id',
                                 values='view').fillna(0)


def recommender_for_user(interact_matrix, df_content, topn=10):
    '''
    Recommender Games for Users
    '''
    pred_scores = interact_matrix.loc[0].values

    df_scores = pd.DataFrame({'content_id': list(users_items_matrix_df.columns),
                              'score': pred_scores})

    df_rec = df_scores.set_index('content_id')\
        .join(df_content.set_index('content_id'))\
        .sort_values('score', ascending=False)\
        .head(topn)[['score', 'game']]

    return df_rec[df_rec.score > 0]


@app.post("/predict")
async def get_user_preds(user_list: List[int]):

    X = np.zeros((1, 4862))
    X[0, user_list] = 1

    # Predict new Matrix Interactions, set score zero on visualized games
    new_matrix = model.predict(X) * (X == 0)

    new_users_items_matrix_df = pd.DataFrame(new_matrix,
                                             columns=users_items_matrix_df.columns)

    # Recommended User Games
    predictions = recommender_for_user(
        interact_matrix=new_users_items_matrix_df,
        df_content=df_game)

    # Return the predictions along with any other relevant data
    return {"predictions": predictions}


# Start the FastAPI server
if __name__ == '__main__':
    import uvicorn
    uvicorn.run(app, host='0.0.0.0', port=8000)
