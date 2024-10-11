unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Edit, FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts,
  REST.Types, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Param,
  FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf, FireDAC.DApt.Intf,
  Data.DB, FireDAC.Comp.DataSet, FireDAC.Comp.Client, REST.Response.Adapter,
  REST.Client, Data.Bind.Components, Data.Bind.ObjectScope, uFormat,
  IPPeerClient;

type
  TForm1 = class(TForm)
    Layout1: TLayout;
    Layout2: TLayout;
    edtCep: TEdit;
    Rectangle1: TRectangle;
    Image2: TImage;
    rectBusca: TRectangle;
    Label1: TLabel;
    lblEndereco: TLabel;
    Image1: TImage;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    RESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    MemTable: TFDMemTable;
    procedure edtCepTyping(Sender: TObject);
    procedure rectBuscaClick(Sender: TObject);
    procedure Label1Exit(Sender: TObject);
  private
    procedure ConsultarCep(cep: String);
    procedure ExecutaDados;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}


// Formatar Texto (CEP)
procedure TForm1.edtCepTyping(Sender: TObject);
begin
 Formatar(edtCep, TFormato.CEP2);
end;


procedure TForm1.Label1Exit(Sender: TObject);
begin
  ConsultarCEP(edtCep.Text);
end;

procedure  TForm1.ConsultarCep(cep: String);
begin
  if SomenteNumero(edtCep.Text).Length <> 8 then
  begin
    ShowMessage('CEP Inválido');
    Exit;
  end;

  try
  RESTRequest1.Resource := 'https://viacep.com.br/ws/' + SomenteNumero(edtCep.Text) + '/json';
  RESTRequest1.Execute;

  if RESTRequest1.Response.StatusCode = 200 then
    ExecutaDados
  else
  begin
    RESTRequest1.Resource := 'https://cdn.apicep.com/file/apicep/' + edtCep.Text + '.json';
    RESTRequest1.Execute;
    if RESTRequest1.Response.StatusCode = 200 then
     ExecutaDados
    else
    begin
      RESTRequest1.Resource := 'https://cep.awesomeapi.com.br/json/' + SomenteNumero(edtCep.Text);
      RESTRequest1.Execute;
      if RESTRequest1.Response.StatusCode = 200 then
       ExecutaDados
      else
       ShowMessage('ERRO ao consultar CEP');
    end;

  End;
  except on e:exception do
   ShowMessage('ERRO ao consultar CEP. Erro: ' + e.Message);
  end;

end;

procedure TForm1.ExecutaDados;
begin
  if RESTRequest1.Response.Content.IndexOf('erro') > 0 then
      ShowMessage('CEP não encontrado')
    else
    begin
      with MemTable do
      begin
        lblEndereco.Text := 'Cidade: ' + FieldByName('localidade').AsString + sLineBreak +
                            'UF: '     + FieldByName('uf').AsString + sLineBreak +
                            'CEP: '    + FieldByName('cep').AsString + sLineBreak +
                            'End: '    + FieldByName('logradouro').AsString + sLineBreak +
                            'Bairro: ' + FieldByName('bairro').AsString + sLineBreak +
                            'Comp: '   + FieldByName('complemento').AsString + sLineBreak +
                            'IGBE: '   + FieldByName('ibge').AsString + sLineBreak +
                            'DDD: '    + FieldByName('ddd').AsString + sLineBreak;
      end;
    end;
end;

procedure TForm1.rectBuscaClick(Sender: TObject);
begin
  ConsultarCEP(edtCep.Text);
end;

end.
