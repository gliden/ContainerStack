unit ContainerStackLib;

interface

uses
  FMX.Layouts, FMX.Forms, System.Generics.Collections, FMX.Types, FMX.Ani;

type
  TAnimationStyle = (None, FromRight, FromLeft, FromTop, FromBottom,
    OverlayFromBottom, OverlayFromTop);

  TClientFormData = class(TObject)
    clientform: TForm;
    clientFormContainer: TLayout;
    mainFormContainer: TLayout;
  end;

  TAnimationFormData = class(TObject)
    clientForm: TForm;
    Animation: TAnimationStyle;
    duration: Single;
    constructor Create(_clientForm: TForm; _animation: TAnimationStyle; _duration: Single);
  end;

  IContainerStackShowNotification = interface
    ['{91636B06-3D21-4ED0-93E3-13E0BFD180A8}']
    procedure WillShow;
  end;

  IContainerStackDidShowNotification = interface
  ['{3D6C263B-0B38-4E0B-AE17-8B266682797A}']
    procedure DidShow;
  end;

  TContainerStack = class(TObject)
  private
    fMainForm: TForm;
    formList: TList<TForm>;
    formLayoutDict: TObjectDictionary<TForm,TClientFormData>;
    fFormStack: TStack<TAnimationFormData>;
    fIsInit: Boolean;
    FInAnimation: Boolean;

    function GetFirstItemOf(fmxObject: TFmxObject; searchClass: TFmxObjectClass): TFmxObject;
    procedure HideAllForms;
    function getVisibleForm: TForm;
    function getBackAnimation(originalAni: TAnimationStyle): TAnimationStyle;

    procedure DoAnimation(currentLayout, newLayout: TLayout; animation: TAnimationStyle; isBackAnimation: Boolean; duration: Single = 0.2);
  private class
    var globalContainerStack: TContainerStack;
  public class
    function Current: TContainerStack;
  public
    property CurrentVisibleForm: TForm read getVisibleForm;
    property IsInit: Boolean read fIsInit;

    constructor Create;
    destructor Destroy;override;
    procedure Initialize(mainForm: TForm);

    procedure RegisterForm(clientform: TForm);overload;
    procedure RegisterForm(clientform: TForm; container: TLayout);overload;

    procedure ShowFormNoAnimation(clientForm: TForm);
    procedure ShowForm(clientForm: TForm; animationStyle: TAnimationStyle; duration: Single = 0.2);

    procedure Back;
    function CanGoBack: Boolean;
  end;

implementation

uses System.SysUtils;

{ TContainerStack }

procedure TContainerStack.Back;
var
  currentData: TAnimationFormData;
  newData: TAnimationFormData;
  currentFormData: TClientFormData;
  newFormData: TClientFormData;
  showInterface: IContainerStackShowNotification;
  didShowInterface: IContainerStackDidShowNotification;
begin
  if not IsInit then exit;

  if fFormStack.Count>1 then
  begin
    currentData := fFormStack.Pop;
    newData := fFormStack.Peek;

    if (not formLayoutDict.TryGetValue(currentData.clientForm, currentFormData)) or
       (not formLayoutDict.TryGetValue(newData.clientForm, newFormData)) then
    begin
      exit;
    end;

    if Supports(newData.clientForm, IContainerStackShowNotification, showInterface) then
    begin
      showInterface.WillShow;
    end;

    DoAnimation(currentFormData.mainFormContainer, newFormData.mainFormContainer, getBackAnimation(currentData.Animation), true, currentData.duration);

    if Supports(newData.clientForm, IContainerStackDidShowNotification, didShowInterface) then
    begin
      didShowInterface.DidShow;
    end;
  end;
end;

function TContainerStack.CanGoBack: Boolean;
begin
  Result := false;
  if not IsInit then exit;

  Result := fFormStack.Count>1;
end;

constructor TContainerStack.Create;
begin
  fIsInit := false;
  FInAnimation := false;

  fMainForm := nil;
  formList := TList<TForm>.Create;
  formLayoutDict := TObjectDictionary<TForm,TClientFormData>.Create([doOwnsValues]);
  fFormStack := TStack<TAnimationFormData>.Create;
end;

class function TContainerStack.Current: TContainerStack;
begin
  if globalContainerStack = nil then globalContainerStack := TContainerStack.Create;
  Result := globalContainerStack;
end;

destructor TContainerStack.Destroy;
begin
  formList.DisposeOf;
  formLayoutDict.DisposeOf;
  inherited;
end;

procedure TContainerStack.DoAnimation(currentLayout, newLayout: TLayout;
  animation: TAnimationStyle; isBackAnimation: Boolean; duration: Single = 0.2);
begin
  currentLayout.Align := TAlignLayout.None;
  currentLayout.Size.Width := fMainForm.ClientWidth;
  currentLayout.Size.Height := fMainForm.ClientHeight;
  currentLayout.Position.X := 0;
  currentLayout.Position.Y := 0;

  newLayout.Align := TAlignLayout.None;
  newLayout.Size.Width := fMainForm.ClientWidth;
  newLayout.Size.Height := fMainForm.ClientHeight;
  newLayout.Visible := true;

  if animation = TAnimationStyle.FromBottom then
  begin
    newLayout.Position.Y := fMainForm.Height;
    newLayout.Position.X := 0;

    TAnimator.AnimateFloat(currentLayout, 'Position.Y',-fMainForm.Height, duration);
    TAnimator.AnimateFloatWait(newLayout, 'Position.Y',0, duration);
  end else
  if animation = TAnimationStyle.FromTop then
  begin
    newLayout.Position.Y := -newLayout.Height;
    newLayout.Position.X := 0;

    TAnimator.AnimateFloat(currentLayout, 'Position.Y',fMainForm.Height, duration);
    TAnimator.AnimateFloatWait(newLayout, 'Position.Y',0, duration);
  end else
  if animation = TAnimationStyle.FromLeft then
  begin
    newLayout.Position.Y := 0;
    newLayout.Position.X := -newLayout.Width;

    TAnimator.AnimateFloat(currentLayout, 'Position.X',fMainForm.Width, duration);
    TAnimator.AnimateFloatWait(newLayout, 'Position.X',0, duration);
  end else
  if animation = TAnimationStyle.FromRight then
  begin
    newLayout.Position.Y := 0;
    newLayout.Position.X := fMainForm.Width;

    TAnimator.AnimateFloat(currentLayout, 'Position.X',-fMainForm.Width, duration);
    TAnimator.AnimateFloatWait(newLayout, 'Position.X',0, duration);
  end else
  if animation = TAnimationStyle.OverlayFromBottom then
  begin
    if isBackAnimation then
    begin
      TAnimator.AnimateFloat(newLayout, 'Opacity', 1, duration);
      TAnimator.AnimateFloatWait(currentLayout, 'Position.Y',-fMainForm.Height, duration);
    end else
    begin
      newLayout.Position.Y := fMainForm.Height;
      newLayout.Position.X := 0;

      newLayout.BringToFront;
      TAnimator.AnimateFloat(currentLayout, 'Opacity', 0.3, duration);
      TAnimator.AnimateFloatWait(newLayout, 'Position.Y',0, duration);
    end;
  end else
  if animation = TAnimationStyle.OverlayFromTop then
  begin
    if isBackAnimation then
    begin
      TAnimator.AnimateFloat(newLayout, 'Opacity', 1, duration);
      TAnimator.AnimateFloatWait(currentLayout, 'Position.Y',fMainForm.Height, duration);
    end else
    begin
      newLayout.Position.Y := -newLayout.Height;
      newLayout.Position.X := 0;

      newLayout.BringToFront;
      TAnimator.AnimateFloat(currentLayout, 'Opacity', 0.3, duration);
      TAnimator.AnimateFloatWait(newLayout, 'Position.Y',0, duration);
    end;
  end;

  newLayout.Align := TAlignLayout.Client;
  currentLayout.Visible := false;
end;

function TContainerStack.getBackAnimation(
  originalAni: TAnimationStyle): TAnimationStyle;
begin
  Result := TAnimationStyle.None;

  case originalAni of
    FromRight: Result := TAnimationStyle.FromLeft;
    FromLeft: Result := TAnimationStyle.FromRight;
    FromTop: Result := TAnimationStyle.FromBottom;
    FromBottom: Result := TAnimationStyle.FromTop;
    OverlayFromBottom: Result := TAnimationStyle.OverlayFromTop;
    OverlayFromTop: Result := TAnimationStyle.OverlayFromBottom;
  end;
end;

function TContainerStack.GetFirstItemOf(fmxObject: TFmxObject;
  searchClass: TFmxObjectClass): TFmxObject;
var
  i: Integer;
begin
  Result := nil;
  for i := 0 to fmxObject.ChildrenCount-1 do
  begin
    if fmxObject.Children[i] is searchClass then
    begin
      Result := fmxObject.Children[i];
      break;
    end;
  end;
end;

function TContainerStack.getVisibleForm: TForm;
begin
  Result := nil;
  if fFormStack.Count>0 then
  begin
    Result := fFormStack.Peek.clientForm;
  end;
end;

procedure TContainerStack.HideAllForms;
var
  clientForm: TForm;
  data: TClientFormData;
begin
  for clientForm in formList do
  begin
    if formLayoutDict.TryGetValue(clientForm, data) then
    begin
      data.mainFormContainer.Visible := false;
    end;
  end;
end;

procedure TContainerStack.Initialize(mainForm: TForm);
begin
  fMainForm := mainForm;
  fIsInit := true;
end;

procedure TContainerStack.RegisterForm(clientform: TForm; container: TLayout);
var
  clientData: TClientFormData;
begin
  if not IsInit then exit;

  if not formList.Contains(clientform) then
  begin
    formList.Add(clientform);

    clientData := TClientFormData.Create;
    clientData.clientform := clientform;
    clientData.clientFormContainer := container;
    clientData.mainFormContainer := TLayout.Create(fMainForm);
    clientData.mainFormContainer.Parent := fMainForm;
    clientData.mainFormContainer.Visible := false;
    container.Parent := clientData.mainFormContainer;

    formLayoutDict.AddOrSetValue(clientform, clientData);
  end;
end;

procedure TContainerStack.ShowForm(clientForm: TForm;
  animationStyle: TAnimationStyle; duration: Single = 0.2);
var
  currentData: TClientFormData;
  newData: TClientFormData;
  newLayout: TLayout;
  currentLayout: TLayout;
  showInterface: IContainerStackShowNotification;
  didShowInterface: IContainerStackDidShowNotification;
begin
  if not IsInit then exit;

  if CurrentVisibleForm = nil then
  begin
    ShowFormNoAnimation(clientForm);
    exit;
  end;
  if CurrentVisibleForm = clientForm then exit;

  if (not formLayoutDict.TryGetValue(CurrentVisibleForm, currentData)) or
     (not formLayoutDict.TryGetValue(clientForm, newData)) then
  begin
    exit;
  end;

  if FInAnimation then exit;

  FInAnimation := true;
  try
    if Supports(clientForm, IContainerStackShowNotification, showInterface) then
    begin
      showInterface.WillShow;
    end;


    currentLayout := currentData.mainFormContainer;
    newLayout := newData.mainFormContainer;

    DoAnimation(currentLayout, newLayout, animationStyle, false, duration);

    if Supports(newData.clientForm, IContainerStackDidShowNotification, didShowInterface) then
    begin
      didShowInterface.DidShow;
    end;

    fFormStack.Push(TAnimationFormData.Create(clientForm,animationStyle, duration));
  finally
    FInAnimation := false;
  end;
end;

procedure TContainerStack.ShowFormNoAnimation(clientForm: TForm);
var
  data: TClientFormData;
  showInterface: IContainerStackShowNotification;
begin
  if not IsInit then exit;
  if FInAnimation then exit;

  FInAnimation := true;
  try
    if Supports(clientForm, IContainerStackShowNotification, showInterface) then
    begin
      showInterface.WillShow;
    end;

    HideAllForms;
    if formLayoutDict.TryGetValue(clientForm, data) then
    begin
      data.mainFormContainer.Align := TAlignLayout.Client;
      data.mainFormContainer.Visible := true;
      fFormStack.Push(TAnimationFormData.Create(clientForm, TAnimationStyle.None, 0));
    end;
  finally
    FInAnimation := false;
  end;
end;

procedure TContainerStack.RegisterForm(clientform: TForm);
var
  layout: TLayout;
begin
  layout := TLayout(GetFirstItemOf(clientForm, TLayout));

  if Assigned(layout) then
  begin
    RegisterForm(clientform, layout);
  end;
end;

{ TAnimationFormData }

constructor TAnimationFormData.Create(_clientForm: TForm;
  _animation: TAnimationStyle; _duration: Single);
begin
  clientForm := _clientForm;
  Animation := _animation;
  duration := _duration;
end;

end.
