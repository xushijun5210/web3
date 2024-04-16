import hashlib
from time import time
from urllib.parse import urlparse
from uuid import uuid4

import requests
from flask import json, Flask, jsonify, request


class Blockchain(object):
    def __init__(self):
        # 构造函数中创建了两个列表，一个用于储存区块链，一个用于储存交易
        self.chain = []
        self.current_transactions = []
        # 构造一个创世块（没有前区块的第一个区块），并给它加上一个工作量证明
        self.new_block(previous_hash=1, proof=100)
        # 储存节点，set避免重复添加节点
        self.nodes = set()

    # 创建新区块
    def new_block(self, previous_hash, proof):
        block = {
            'index': len(self.chain) + 1,
            'timestamp': time(),
            'transactions': self.current_transactions,
            'proof': proof,
            'previous_hash': previous_hash or self.hash(self.chain[-1]),
        }
        # 重置当前交易记录列表
        self.current_transactions = []
        self.chain.append(block)
        return block

    # 加入交易，到交易列表
    def new_transaction(self, sender: str, recipient: str, amount: int):
        """
        生成新交易信息，信息将加入到下一个待挖的区块中
        :param sender: <str> Address of the Sender
        :param recipient: <str> Address of the Recipient
        :param amount: <int> Amount
        :return: <int> The index of the Block that will hold this transaction
        """
        self.current_transactions.append({
            'sender': sender,
            'recipient': recipient,
            'amount': amount,
        })
        return self.last_block['index'] + 1

    @staticmethod
    def hash(block):
        """
        生成块的 SHA-256 hash值
        :param block: <dict> Block
        :return: <str>
        """
        # 确保字典是有序的，避免出现不一致的哈希
        block_string = json.dumps(block, sort_keys=True).encode()
        return hashlib.sha256(block_string).hexdigest()

    @property
    def last_block(self):
        # 返回链中的最后一个块
        return self.chain[-1]

    # 工作量证明
    def proof_of_work(self, last_proof):
        """
        简单的工作量证明:
        - 查找一个 p' 使得 hash(pp') 以4个0开头
        - p 是上一个块的证明,  p' 是当前的证明
        :param last_proof: <int>
        :return: <int>
        """
        proof = 0
        while self.valid_proof(last_proof, proof) is False:
            proof += 1
        return proof

    @staticmethod
    def valid_proof(last_proof, proof):
        """
        验证证明: 是否hash(last_proof, proof)以4个0开头?
        :param last_proof: <int> Previous Proof
        :param proof: <int> Current Proof
        :return: <bool> True if correct, False if not.
        """
        guess = f'{last_proof}{proof}'.encode()
        guess_hash = hashlib.sha256(guess).hexdigest()
        return guess_hash[:4] == "0000"

    def register_node(self, address):
        """
        Add a new node to the list of nodes
        :param address: <str> Address of node. Eg. 'http://192.168.0.5:5000'
        :return: None
        """
        parsed_url = urlparse(address)
        self.nodes.add(parsed_url.netloc)

    def valid_chain(self, chain):
        """
        Determine if a given blockchain is valid
        :param chain: <list> A blockchain
        :return: <bool> True if valid, False if not
        """

        last_block = chain[0]
        current_index = 1

        while current_index < len(chain):
            block = chain[current_index]
            print(f'{last_block}')
            print(f'{block}')
            print("\n-----------\n")
            # Check that the hash of the block is correct
            if block['previous_hash'] != self.hash(last_block):
                return False

            # 检查工作证明是否正确
            if not self.valid_proof(last_block['proof'], block['proof']):
                return False

            last_block = block
            current_index += 1

        return True

    def resolve_conflicts(self):
        """
        共识算法解决冲突
        使用网络中最长的链.
        :return: <bool> True 如果链被取代, 否则为False
        """

        neighbours = self.nodes
        new_chain = None

        # 找出最长的链
        max_length = len(self.chain)

        # 获取并验证网络中所有节点的链并验证
        for node in neighbours:
            response = requests.get(f'http://{node}/chain')

            if response.status_code == 200:
                length = response.json()['length']
                chain = response.json()['chain']

                # Check if the length is longer and the chain is valid
                if length > max_length and self.valid_chain(chain):
                    max_length = length
                    new_chain = chain

        # 如果发现更换长的链就替换
        if new_chain:
            self.chain = new_chain
            return True

        return False

    # Blockchain作为API接口
    # 实例化我们的节点


app = Flask(__name__)
# 为此节点生成全局唯一地址
node_identifier = str(uuid4()).replace('-', '')

# 实例化区块链
blockchain = Blockchain()


# todo(yinxing) 挖矿产生交易并添加新块，新增交易只记录交易信息不产生新区块？
# 创建一个交易并添加到区块
@app.route('/transactions/new', methods=['POST'])
def new_transaction():
    values = request.get_json()

    # Check that the required fields are in the POST'ed data
    required = ['sender', 'recipient', 'amount']
    if not all(k in values for k in required):
        return 'Missing values', 400

    # Create a new Transaction
    index = blockchain.new_transaction(values['sender'], values['recipient'], values['amount'])

    response = {'message': f'Transaction will be added to Block {index}'}
    return jsonify(response), 201


# 挖矿
# 1.计算工作量证明PoW
# 2.通过新增一个交易授予矿工（自己）一个币
# 3.构造新区块并将其添加到链中
# 告诉服务器去挖掘新的区块
@app.route('/mine', methods=['GET'])
def mine():
    # 我们运行工作证明算法来获得下一个证明。。。
    last_block = blockchain.last_block
    last_proof = last_block['proof']
    proof = blockchain.proof_of_work(last_proof)

    # todo(yinxing) 原始的区块是哪里来的（旧理解：初始化一个固定值，逐步减么）？这里是直接给1个币奖励
    # 给工作量证明的节点提供奖励
    # 发送者为 "0" 表明是新挖出的币
    blockchain.new_transaction(
        sender="0",
        recipient=node_identifier,
        amount=1,
    )

    # 通过将新块添加到链中来锻造它
    block = blockchain.new_block(proof)

    response = {
        'message': "New Block Forged",
        'index': block['index'],
        'transactions': block['transactions'],
        'proof': block['proof'],
        'previous_hash': block['previous_hash'],
    }
    return jsonify(response), 200


# 返回整个区块链
@app.route('/chain', methods=['GET'])
def full_chain():
    response = {
        'chain': blockchain.chain,
        'length': len(blockchain.chain),
    }
    return jsonify(response), 200


# 注册节点
@app.route('/nodes/register', methods=['POST'])
def register_nodes():
    values = request.get_json()

    nodes = values.get('nodes')
    if nodes is None:
        return "Error: Please supply a valid list of nodes", 400

    for node in nodes:
        blockchain.register_node(node)

    response = {
        'message': 'New nodes have been added',
        'total_nodes': list(blockchain.nodes),
    }
    return jsonify(response), 201


# 解决链冲突
@app.route('/nodes/resolve', methods=['GET'])
def consensus():
    replaced = blockchain.resolve_conflicts()

    if replaced:
        response = {
            'message': 'Our chain was replaced',
            'new_chain': blockchain.chain
        }
    else:
        response = {
            'message': 'Our chain is authoritative',
            'chain': blockchain.chain
        }

    return jsonify(response), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8888)
