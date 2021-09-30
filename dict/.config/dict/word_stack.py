#!/usr/bin/env python3

import argparse
import json
import logging
import os
import random
import sys
import time
from typing import Any

import requests as rq

API_URL = "https://api.tianapi.com/txapi/enwords/index"


def load_api_key() -> str:
    api_key = os.environ.get('DICT_API_KEY')
    if api_key is None:
        logging.error("Can not load api key")
        sys.exit(1)
    return api_key


def get_chinese_meaning(api_key: str, word: str):
    req_playload = {"key": api_key, "word": word}
    req = rq.get(API_URL, params=req_playload)
    if req.status_code != 200:
        logging.error("error connection to api server")
        sys.exit(2)

    json_response = req.json()
    if json_response['code'] != 200 and json_response['code'] != 250:
        logging.error(
            f"error from api server: code:{json_response['code']}, msg: {json_response['msg']}")
        sys.exit(3)

    if json_response['code'] == 250:
        logging.warning(
            f"error from api server: code:{json_response['code']}, msg: {json_response['msg']}")
        return "NotExistInDict"

    if len(json_response['newslist']) < 1:
        logging.error(f"no return result")
        sys.exit(4)

    return_res = json_response['newslist'][0]

    if return_res['word'] != word:
        logging.error(
            f"the input {word} and reture {return_res['word']} not match!")
        sys.exit(5)

    return return_res['content']


def load_stack_file(file_path: str) -> list[str]:
    word_stack = []
    with open(file_path, 'r') as stack_file:
        word_stack = [i.replace("\n", "")
                      for i in stack_file.readlines() if i != "\n"]
    logging.debug(f"Load stack file {file_path} with {len(word_stack)} words")
    return word_stack


def load_dict_file(file_path: str) -> Any:
    word_dict = {}

    with open(file_path, 'r') as dict_file:
        dict_content = dict_file.read()
        word_dict = json.loads(dict_content)

    logging.debug(f"Load dict file {file_path} with {len(word_dict)} elements")

    return word_dict


def dump_dict_file(file_path: str, word_dict: Any):
    with open(file_path, 'w') as dict_file:
        dict_file.write(json.dumps(word_dict, indent=4))
        logging.debug("Dumping dict file {file_path}")


def dump_stack_file(file_path: str, stack: list[str]):
    with open(file_path, 'w') as stack_file:
        # print(stack)
        stack_file.write("\n".join(stack))
        logging.debug("Dumping stack file {file_path}")


def push_to_stack(stack: list[str], word: str) -> list[str]:
    if word not in stack:
        stack.append(word)
        logging.debug(f"Puth {word} to stack")
    else:
        logging.debug(f"The {word} is already pushed to stack")
    return stack


def push_to_dict(api_key, word_dict: Any, word: str) -> Any:
    if word not in word_dict.keys():
        meaning = get_chinese_meaning(api_key, word)
        word_dict[word] = {'meaning': meaning, 'count': 1,
                           'created': time.time(), 'last_updated':  time.time()}
    else:
        word_dict[word]['last_updated'] = time.time()
        word_dict[word]['count'] += 1
    return word_dict


def pop_from_stack(stack: list[str], num: int = 1) -> list[str]:
    poped_words = []
    poped_index = []
    i = random.randint(0, len(stack) - 1)
    poped_index.append(i)
    poped_words.append(stack[i])

    num = min(num, len(stack))

    while len(poped_words) < num:
        i = random.randint(0, len(stack) - 1)
        if i not in poped_index:
            poped_index.append(i)
            poped_words.append(stack[i])

    return poped_words


def load_from_dict(word_dict, words: list[str]) -> Any:
    word_meaning_pairs = []
    for word in words:
        if word in word_dict.keys():
            meaning = word_dict[word]['meaning']
        else:
            meaning = "NotFound"
        word_meaning_pairs.append((word, meaning))
    return word_meaning_pairs


if __name__ == "__main__":

    parser = argparse.ArgumentParser("Word stack: add unkonwn words to stack")

    parser.add_argument("-s", "--stack", type=str,
                        default="~/.config/dict/word_stack.txt", help="the path to the stack file")
    parser.add_argument("-d", "--dict", type=str,
                        default="~/.config/dict/word_dict.json", help="the chinese meaning of word")
    parser.add_argument("--push", action="store_true",
                        help="push to the stack")
    parser.add_argument("--pop", action="store_true",
                        help="pop from the stack")
    parser.add_argument("--delete", action="store_true",
                        help="delect from the stack")
    parser.add_argument("-p", "--pop-num", type=int, default=1,
                        help="pop num of words from the stack")
    parser.add_argument("--word", type=str, default="", help="the word")

    parser.add_argument("--api", default="", type=str, help="api key")

    args = parser.parse_args()

    if not os.path.exists(args.stack):
        logging.error(f"Stack file {args.stack} not exists")
        sys.exit(1)

    if not os.path.exists(args.dict):
        logging.error(f"Dict file {args.dict} not exists")
        sys.exit(1)

    stack = load_stack_file(args.stack)
    word_dict = load_dict_file(args.dict)
        
    api_key = ""

    if len(args.api) == 32:
        api_key = args.api
    else:
        api_key = load_api_key()

    if args.push:
        stack = push_to_stack(stack, args.word)
        dump_stack_file(args.stack, stack)
        word_dict = push_to_dict(api_key, word_dict, args.word)
        dump_dict_file(args.dict, word_dict)
        print(f"{args.word} add to stack and dict")

    if args.pop:
        poped_words = pop_from_stack(stack, args.pop_num)
        poped_word_meaning_pairs = load_from_dict(word_dict, poped_words)
        for pair in poped_word_meaning_pairs:
            print(f"{pair[0]}:\n\t{pair[1]}")

    if args.delete:
        logging.waring("Delete method have not been NotImplemented")
