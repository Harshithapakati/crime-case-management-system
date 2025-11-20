from flask_bcrypt import Bcrypt
bcrypt = Bcrypt()

# For Amit
amit_hash = bcrypt.generate_password_hash("Amit@123").decode("utf-8")
print("Amit Hash:", amit_hash)

# For Neha
neha_hash = bcrypt.generate_password_hash("Neha@123").decode("utf-8")
print("Neha Hash:", neha_hash)
