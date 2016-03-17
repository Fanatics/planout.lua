const Promise = require('bluebird')
const fs = require('fs')
const writer = require("./lua-writer")

const input = {
  'op': 'seq',
  'id': 'seq_1',
  'seq': [
    {
      'op': 'set',
      'id': 'set_1',
      'var': 'group_size',
      'value': {
        'choices': {'op': 'array','id': 'arr_1', 'values': [1,10]},
        'unit': {
          'op': 'get',
          'id': 'get_1',
          'var': 'userid'
        },
        'id': 'uc_1',
        'op': 'uniformChoice'
      }
    },
    {
      'op': 'set',
      'id': 'set_2',
      'var': 'specific_goal',
      'value': {
        'p': 0.8,
        'unit': {
          'op': 'get',
          'id': 'get_2',
          'var': 'userid'
        },
        'id': 'bt_1',
        'op': 'bernoulliTrial'
      }
    },
    {
      'op': 'cond',
      'id': 'cond_1',
      'cond': [
        {
          'if': {
            'op': 'get',
            'id': 'get_3',
            'var': 'specific_goal'
          },
          'then': {
            'op': 'seq',
            'id': 'seq_2',
            'seq': [
              {
                'op': 'set',
                'id': 'set_3',
                'var': 'ratings_per_user_goal',
                'value': {
                  'choices': {
                    'op': 'array',
                    'id': 'arr_2',
                    'values': [8,16,32,64]
                  },
                  'unit': {
                    'op': 'get',
                    'id': 'get_4',
                    'var': 'userid'
                  },
                  'id': 'uc_2',
                  'op': 'uniformChoice'
                }
              },
              {
                'op': 'set',
                'id': 'set_4',
                'var': 'ratings_goal',
                'value': {
                  'op': 'product',
                  'id': 'prod_1',
                  'values': [
                    {
                      'op': 'get',
                      'id': 'get_5',
                      'var': 'group_size'
                    },
                    {
                      'op': 'get',
                      'id': 'get_6',
                      'var': 'ratings_per_user_goal'
                    }
                  ]
                }
              }
            ]
          }
        }
      ]
    }
  ]
}
writer.parse(input)
