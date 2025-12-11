from odoo import models, fields


class EstateProperty(models.Model):
    _name = "estate.property"
    _description = "Tabela com as propriedades imobiliárias"

    name = fields.Char(string="Nome", required=True)
    description = fields.Text(string="Descrição")
    postcode = fields.Char(string="CEP")
    date_availability = fields.Date(string="Data de disponibilidade")
    expected_price = fields.Float(string="Preço esperado", required=True)
    selling_price = fields.Float(string="Preço de venda")
    bedrooms = fields.Integer(string="Quartos")
    living_area = fields.Integer(string="Área útil")
    facades = fields.Integer(string="Fachadas")
    garage = fields.Boolean(string="Garagem")
    garden = fields.Boolean(string="Jardim")
    garden_area = fields.Integer(string="Área do jardim")
    garden_orientation = fields.Selection(
        [
            ("north", "Norte"),
            ("south", "Sul"),
            ("east", "Leste"),
            ("west", "Oeste"),
        ],
        string="Orientação do jardim",
    )
