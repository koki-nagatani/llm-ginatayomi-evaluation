import argparse
import codecs
from collections import OrderedDict

import pandas as pd
import yaml


# increase indent of nested lists
class MyDumper(yaml.Dumper):
    def increase_indent(self, flow=False, indentless=False):
        return super(MyDumper, self).increase_indent(flow, False)

# represent OrderedDict as a normal dict
def represent_odict(dumper, instance):
    return dumper.represent_mapping('tag:yaml.org,2002:map', instance.items())

yaml.add_representer(OrderedDict, represent_odict)

parser = argparse.ArgumentParser(description='Convert CSV to YAML')
parser.add_argument('input', type=str, help='Input CSV file')
parser.add_argument('output', type=str, help='Output YAML file')
args = parser.parse_args()

df = pd.read_csv(args.input)

test_cases = []
for row in df.itertuples():
    test_case = OrderedDict({
        "vars": {"input": row.input},
        "assert": [
            {
                "type": "contains-all",
                "value": [row.expected1, row.expected2]
            }
        ]
    })
    test_cases.append(test_case)

with codecs.open(args.output, 'w') as f:
    yaml.dump(test_cases, f, sort_keys=False, encoding="utf-8", allow_unicode=True, Dumper=MyDumper, default_flow_style=False)
