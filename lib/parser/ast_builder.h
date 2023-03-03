#include <vector>

enum ast_node_type {
    TYPE_PROGRAM,
    TYPE_ELEMENTS,
    TYPE_ELEMENT,
    TYPE_ATOM,
    TYPE_LITERAL,
    TYPE_LIST,
    TYPE_INTEGER,
    TYPE_REAL,
    TYPE_BOOLEAN,
    TYPE_NULL
};

typedef struct ast_node {
    int type;
    void *data;
    std::vector<ast_node> *children;
} ast_node;

void create_program_ast(void *elements);
ast_node *make_empty_elements_node();
ast_node *make_recursive_elements_node(void *element, void *elements);
ast_node *make_element_node(void *element);
ast_node *make_list_node(void *element);
ast_node *make_atom_node(char *identifier);
ast_node *make_literal_node(void *literal);
ast_node *make_integer_node(int number);
ast_node *make_real_node(int integer_part, int fractional_part);
ast_node *make_boolean_node(int boolean);
ast_node *make_null_node();
void print_ast();
