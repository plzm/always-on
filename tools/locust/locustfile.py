import random, uuid
from locust import HttpUser, task, between

class MyUser(HttpUser):
	wait_time = between(0, 0.25)

	@task(1)
	def get_profile(self):
		handle = str(random.randint(1, 1000))
		self.client.get("/" + handle)

	@task(1)
	def post_profile(self):
		handle = str(random.randint(1, 1000))
		avatar_url = "http://foo/" + handle + ".jpg"
		total_xp = random.randint(1, 10000)
		self.client.post("/profile", json={"id": f"{handle}", "Handle": f"{handle}", "AvatarUrl": f"{avatar_url}", "TotalXp": f"{total_xp}"})

	@task(1)
	def post_progress(self):
		progress_id=str(uuid.uuid4())
		handle = str(random.randint(1, 1000))
		xp = random.randint(1, 100)
		self.client.post("/progress", json={"id": f"{progress_id}", "Handle": f"{handle}", "Xp": f"{xp}"})
