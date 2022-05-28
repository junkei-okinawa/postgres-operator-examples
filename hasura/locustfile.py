from locust import HttpUser, TaskSet, task

import json
import pandas as pd

url = '/v1/graphql'
header = {'content-type': 'application/json'}
test_query = '''
query MyQuery {
  test_table_aggregate {
    aggregate {
      count
    }
  }
}
'''
data = {"query" : test_query}
json_data = json.dumps(data)
with open('insert_one_recode.gql') as gql_file:
    query = gql_file.read()


class UserBehavior(HttpUser):
    # def on_start(self):
    #     self.get()

    # def on_stop(self):
    #     self.insert()

    @task
    def get(self):
        self.df = False
        self.max_id = False
        with self.client.post(url=url, headers=header, data=json_data, catch_response = True) as response:
            if response.status_code != 200:
                response.failure("not authenticated???")
            else:
                self.max_id = int(response.json()['data']['test_table_aggregate']['aggregate']['count'])
        
        if self.max_id:
            data = {'id': self.max_id + 1, 'name': f'aaa'}
            with self.client.post(url=url, headers=header, json={'query': query, 'variables': data}, catch_response = True) as response:
                if response.status_code != 200:
                    response.failure("not authenticated???")

        # self.client.post(self.url, {"username": "admin", "password": "admin-password", csrf_param: csrf_token})
    
    # @task
    # def insert(self):
    #     if self.max_id:
    #         data = {'id': self.max_id + 1, 'name': f'aaa'}
    #         with self.client.post(url=self.url, headers=self.header, json={'query': self.query, 'variables': data}, catch_response = True) as response:
    #             if response.status_code != 200:
    #                 response.failure("not authenticated???")

    # @task
    # def top(self):
    #     self.client.get("/")

    # @task(2)
    # def mypage(self):
    #     with self.client.get("/my/page", catch_response = True) as response:
    #         if response.status_code != 200:
    #             response.failure("not authenticated???")

    # @task
    # def projects(self):
    #     self.client.get("/projects")

# class RedmineUser(HttpUser):
#     task_set = UserBehavior
#     min_wait = 500
#     max_wait = 1000

# locust --host=http://192.168.10.122:8080
