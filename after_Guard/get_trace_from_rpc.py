import pickle
from eth_rpc_api import EthJsonRpc
import requests
import os
import time
import json

session = requests.Session()

def getTraceTransactionRPC(tx):
    global session
    method = 'debug_traceTransaction'
    params = [tx,{"disableStack": False, "disableMemory": False, "disableStorage": False}]
    payload = {"jsonrpc": "2.0",
               "method": method,
               "params": params,
               "id": 1}
    headers = {'Content-type': 'application/json'}
    data = None
    try:
        response = session.post('http://localhost:8500', json=payload, headers=headers)
    except Exception as e:
        return None
    data = response.json()
    return data


def get_execution_record(count = 0,attack_flag = -10,petflag=False):
    rpc = EthJsonRpc('127.0.0.1', 8500)
    max_block = rpc.eth_blockNumber()

    contract_to_last_tx_hash = {}
    all_trace = []
    attack = None
    migreate = None
    pertect = None
    for current_block_num in range(0, max_block + 1):
        block = rpc.eth_getBlockByNumber(current_block_num, True)
        transactions = block["transactions"]
        for i in range(0, len(transactions)):
            transaction = transactions[i]
            if transaction == None:
                continue
            if transaction["to"] == None:
                continue
            if transaction["to"] not in contract_to_last_tx_hash:
                contract_to_last_tx_hash[transaction["to"]] = []
            transaction_hash = transaction["hash"]
            contract_to_last_tx_hash[transaction["to"]].append(transaction_hash)
            all_trace.append((transaction["to"],transaction_hash))

    for id,obj in enumerate(contract_to_last_tx_hash.items()):
        if id == 0:
            migreate = obj[0]
        if id == 1:
            pertect = obj[0]
        if len(obj[1]) == 1:
            attack = obj[0]
        # if len(value) == 1:
        #     attack = key
        #     break
        pass

    order_trace = []
    line_count = 0
    file_count = 0
    for tx_to,one_tx in all_trace:
        line_count += 1
        flag = 0
        if tx_to == migreate:
            continue
        if tx_to == attack:
            flag = 1
        if line_count == attack_flag:
            flag = 1
        trace_info = getTraceTransactionRPC(one_tx)

        f = open("./%d.json" % file_count, "w+")
        json_data = json.dumps(trace_info)
        f.write(json_data)
        f.close()
        file_count += 1;

        complete_trace = trace_info["result"]["structLogs"]



        retrun_value = trace_info["result"]["returnValue"]
        trace_gas = trace_info["result"]["gas"]
        if retrun_value is not "":
            aaa = 0
        before_step = None
        all_ins = []
        for id,step in enumerate(complete_trace):
            info = {}
            if before_step and before_step["depth"] < step["depth"]:
                all_ins[id-1]["stack"] = before_step["stack"][-2]
                if petflag:
                    pertect = before_step["stack"][-2]
            info["depth"] = step["depth"]
            info["pc"] = step["pc"]
            before_step = step
            all_ins.append(info)
        all_ins = (flag,tx_to,all_ins,trace_gas)
        order_trace.append(all_ins)

    output_data = (pertect,order_trace)
    f = open("./trace/%d" % count, "wb")
    pickle.dump(output_data,f)
    f.close()

gannache_cmd = "ganache-cli -i 10 -e 10000 -a 500 -p 8500 > ganachi-out &"

def read_pic(file_path):
    f = open(file_path,"rb+")
    g = pickle.load(f)
    f.close()
    return g

def find_attack(path):
    f = open(path, "r+")
    data = f.readlines()
    f.close()
    count = 0
    for line in data:
        if line.find("new") is not -1 or line.find("let") is not -1:
            continue
        if line.find("await") is not -1:
            count += 1
            continue
        if line.find("attack") is not -1:
            count += 1
            break
    return count

if __name__ == '__main__':
    root_path = "/home/xcrab/MyWorkspace/DEMO_Guard"
    all_contracts = os.listdir(root_path)
    for contract in all_contracts:
        if os.path.isfile(contract):
            continue
        path = root_path + "/" + contract
        os.chdir(path)
        test_path = "./test"
        dirs = os.listdir(test_path)
        os.system("pkill -9 node")
        for id,item in enumerate(dirs):
            petflag = False
            print("gannache")
            os.system(gannache_cmd)
            time.sleep(5)
            print("truffle")
            attack_index = -10
            if item.find("BecToken") is not -1 or item.find("DaoCha") is not -1:
                attack_index = find_attack(test_path + "/" + item)
            if item.find("Wallet") is not -1:
                petflag = True
            truffle_cmd = "truffle test %s --network test > out" % (test_path + "/" + item)
            print(truffle_cmd)
            os.system(truffle_cmd)
            get_execution_record(id,attack_index+2,petflag)
            os.system("pkill -9 node")
    pass