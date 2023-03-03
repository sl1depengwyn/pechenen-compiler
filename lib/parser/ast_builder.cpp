#include "ast_builder.h"
#include <stdlib.h>
#include <iostream>
#include <sstream>
#include <vector>
#include <string>

using namespace std;

ast_node *program_ast;

ast_node *_make_empty_node(int type) {
    ast_node *node = (ast_node*)(malloc(sizeof(ast_node)));
    node->type = type;
    node->data = NULL;
    node->children = new vector<ast_node>;
    return node;
}

ast_node _convert_to_node(void* node) {
    return *((ast_node*)(node));
}

void create_program_ast(void *elements_p) {
    ast_node elements = _convert_to_node(elements_p);

    ast_node *node = _make_empty_node(TYPE_PROGRAM);
    node->children->push_back(elements);
    program_ast = node;
}

ast_node *make_empty_elements_node() {
    ast_node *node = _make_empty_node(TYPE_ELEMENTS);
    return node;
}

void _print_ast_node(ast_node node, int level);

ast_node *make_recursive_elements_node(void *element_p, void *elements_p) {
    ast_node element = _convert_to_node(element_p);
    ast_node elements = _convert_to_node(elements_p);
    ast_node *node = _make_empty_node(TYPE_ELEMENTS);

    node->children->push_back(element);
    for (int i = 0; i < elements.children->size(); i++) {
        node->children->push_back((*elements.children)[i]);
    }

    return node;
}

ast_node *make_element_node(void *element_p) {
    ast_node element = _convert_to_node(element_p);

    ast_node *node = _make_empty_node(TYPE_ELEMENT);
    node->children->push_back(element);
    return node;
}

ast_node *make_list_node(void *element_p) {
    ast_node element = _convert_to_node(element_p);

    ast_node *node = _make_empty_node(TYPE_LIST);
    node->children->push_back(element);
    return node;
}

ast_node *make_atom_node(char *identifier) {
    ast_node *node = _make_empty_node(TYPE_ATOM);
    node->data = identifier;
    return node;
}

ast_node *make_literal_node(void *literal_p) {
    ast_node literal = _convert_to_node(literal_p);

    ast_node *node = _make_empty_node(TYPE_LITERAL);
    node->children->push_back(literal);
    return node;
}

ast_node *make_integer_node(int number) {
    ast_node *node = _make_empty_node(TYPE_INTEGER);
    int *data = (int*)malloc(sizeof(int));
    *data = number;
    node->data = data;
    return node;
}

ast_node *make_real_node(int integer_part, int fractional_part) {    
    double fractinal_part_divisor = 1;
    int fractional_part_copy = fractional_part;
    while (fractional_part_copy != 0) {
        fractinal_part_divisor *= 10;
        fractional_part_copy /= 10;
    }
    double real = integer_part + fractional_part / fractinal_part_divisor;

    ast_node *node = _make_empty_node(TYPE_REAL);
    double *data = (double*)malloc(sizeof(double));
    *data = real;
    node->data = data;
    return node;
}

ast_node *make_boolean_node(int boolean) {
    ast_node *node = _make_empty_node(TYPE_BOOLEAN);
    int *data = (int*)malloc(sizeof(int));
    *data = boolean;
    node->data = data;
    return node;
}

ast_node *make_null_node() {
    return _make_empty_node(TYPE_NULL);
}

string _get_ast_node_type_name(int type) {
    switch (type) {
        case TYPE_PROGRAM:
            return "PROGRAM";
        case TYPE_ELEMENTS:
            return "ELEMENTS";
        case TYPE_ELEMENT:
            return "ELEMENT";
        case TYPE_ATOM:
            return "ATOM";
        case TYPE_LITERAL:
            return "LITERAL";
        case TYPE_LIST:
            return "LIST";
        case TYPE_INTEGER:
            return "INTEGER";
        case TYPE_REAL:
            return "REAL";
        case TYPE_BOOLEAN:
            return "BOOLEAN";
        case TYPE_NULL:
            return "NULL";
    }

    return "UNKNOWN";
}

string _double_to_string(double val) {
    ostringstream strs;
    strs << val;
    return strs.str();
}

string _int_to_string(int val) {
    ostringstream strs;
    strs << val;
    return strs.str();
}

string _boolean_to_string (int val) {
    if (val) {
        return "true";
    }
    return "false";
}

string _get_ast_node_value_string(ast_node node) {
    switch (node.type) {
        case TYPE_ATOM:
            return "\"" + string((char*)(node.data)) + "\"";
        case TYPE_INTEGER:
            return _int_to_string(*(int*)(node.data));
        case TYPE_REAL:
            return _double_to_string(*(double*)(node.data));
        case TYPE_BOOLEAN:
            return _boolean_to_string(*(int*)(node.data));
    }

    return "";
}

void _print_ast_node(ast_node node, int level) {
    for (int i = 0; i < level; i++) {
        cout << "- ";
    }
    cout << _get_ast_node_type_name(node.type) << " " << _get_ast_node_value_string(node) << endl;
    for (int i = 0; i < node.children->size(); i++) {
        _print_ast_node((*node.children)[i], level + 1);
    }
}

void print_ast() {
    _print_ast_node(*program_ast, 0);
}
