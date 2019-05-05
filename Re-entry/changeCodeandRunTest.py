import os
import pickle
import sys
import demjson

bytecode = sys.argv[1]
deployedBytecode = sys.argv[2]
target_contract = sys.argv[3]

def getJsonData(file_path):
    with open(file_path, "r") as f:
        data = f.read()
        f.close()
        data = demjson.decode(data, "utf-8")
        return data


def writeJsonData(data, file_path):
    f = open(file_path, "w+")
    sjson = demjson.encode(data)
    f.write(sjson)
    f.close()

if os.path.exists(os.path.abspath('.') + "/build"):
    rm_cmd = "rm -r build"
    os.system(rm_cmd)

truffle_compile = "truffle compile"
os.system(truffle_compile)

ast_json = getJsonData(("./build/contracts/" + target_contract + ".json"))
ast_json["bytecode"] = bytecode
ast_json["deployedBytecode"] = deployedBytecode
writeJsonData(ast_json, ("./build/contracts/" + target_contract + ".json"))

truffle_test_cmd = "truffle test --network test"
os.system(truffle_test_cmd)




