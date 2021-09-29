#!/usr/bin/env python3

import argparse
import logging
import os
import random
import sys


def load_stack_file(file_path: str) -> list[str]:
    word_stack = []
    with open(file_path, 'r') as stack_file:
        word_stack = [i.replace("\n", "") for i in stack_file.readlines() if i != "\n"]
    logging.debug(f"Load stack file {file_path} with {len(word_stack)} words")
    return word_stack


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


if __name__ == "__main__":

    parser = argparse.ArgumentParser("Word stack: add unkonwn words to stack")

    parser.add_argument("-s", "--stack", type=str,
                        default="~/.config/dict/word_stack.txt", help="the path to the stack file")
    parser.add_argument("--push", action="store_true",
                        help="push to the stack")
    parser.add_argument("--pop", action="store_true",
                        help="pop from the stack")
    parser.add_argument("--delete", action="store_true",
                        help="delect from the stack")
    parser.add_argument("-p", "--pop-num", type=int, default=1, help="pop num of words from the stack")
    parser.add_argument("--word", type=str, default="", help="the word")

    args = parser.parse_args()

    if  not os.path.exists(args.stack):
        logging.error(f"Stack file {args.stack} not exists")
        sys.exit(1)

    stack = load_stack_file(args.stack)

    if args.push:
        stack = push_to_stack(stack, args.word)
        print(f"{args.word} add to stack")
        dump_stack_file(args.stack, stack)

    if args.pop:
        poped_words = pop_from_stack(stack, args.pop_num)
        for word in poped_words:
            print(word)

    if args.delete:
        logging.waring("Delete method have not been NotImplemented")


