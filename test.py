import json

def compare_json(file1_path, file2_path):
    with open(file1_path, 'r') as file1, open(file2_path, 'r') as file2:
        json1 = json.load(file1)
        json2 = json.load(file2)

        if json1 == json2:
            print("JSON files are identical.")
        else:
            print("JSON files are different.")

if __name__ == "__main__":
    file1_path = "output.json"
    file2_path = "out2.json"
    compare_json(file1_path, file2_path)

